#Requires -Version 7.2
<#
.SYNOPSIS
   Sets up (or checks) a KofTwentyTwo development workstation on Windows, macOS, or Linux.

.DESCRIPTION
   Implements the workstation standard (standards/workstation.md, K22-WS-*):

   1. Installs the core tools every KofTwentyTwo repository needs (git, GitHub CLI, uv,
      Node.js, gitleaks, Trivy, OSV-Scanner, actionlint, zizmor, pre-commit, 1Password
      and its CLI), plus optional language toolchains.
   2. Configures git to sign every commit and tag with an SSH key held in 1Password and
      served by the 1Password SSH agent, so no private key exists on disk (K22-SEC-14).
   3. Checks the machine against the security baseline (disk encryption, firewall,
      malware protection, stray private keys) and reports PASS / WARN / FAIL.

   The script is idempotent: run it again at any time to repair or update a machine.
   It never generates keys and never reads secrets; keys are created in 1Password.
   Supports -WhatIf to show what would change.

.PARAMETER Languages
   Optional language toolchains to install: dotnet, java, python, rust, go, swift, shell,
   terraform.

.PARAMETER SigningKey
   Part of the name of the 1Password SSH key to sign commits with, for example "GitHub".
   When omitted and the agent holds several keys, the script asks.

.PARAMETER RegisterSigningKey
   Also upload the signing key's public half to GitHub as a signing key (gh CLI).

.PARAMETER CheckOnly
   Change nothing; only report the workstation's state.

.PARAMETER SkipGitConfig
   Install tools but leave the global git configuration alone.

.EXAMPLE
   ./Install-Workstation.ps1 -Languages dotnet,java -SigningKey GitHub -RegisterSigningKey

.EXAMPLE
   ./Install-Workstation.ps1 -CheckOnly
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive installer: colored console output is its user interface.')]
[CmdletBinding(SupportsShouldProcess)]
param(
   # Validated after splitting: `pwsh -File` (used by the bootstraps) passes "dotnet,java"
   # as a single string.
   [string[]] $Languages = @(),

   [string] $SigningKey,

   [switch] $RegisterSigningKey,

   [switch] $CheckOnly,

   [switch] $SkipGitConfig
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$supportedLanguages = @('dotnet', 'java', 'python', 'rust', 'go', 'swift', 'shell', 'terraform')
$Languages = @($Languages | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
$unknown = @($Languages | Where-Object { $_ -notin $supportedLanguages })
if ($unknown.Count -gt 0)
{
   throw "Unknown language(s): $($unknown -join ', '). Supported: $($supportedLanguages -join ', ')."
}



#################################################################################
# Tool catalog: what to install, how to detect it, and the package id per OS.   #
# Winget ids are verified against the winget community source; Brew entries    #
# marked Cask are macOS-only (Homebrew casks do not exist on Linux).           #
#################################################################################
$script:Catalog = @(
   @{ Group = 'core'; Name = 'git'; Command = 'git'; Winget = 'Git.Git'; Brew = 'git' }
   @{ Group = 'core'; Name = 'GitHub CLI'; Command = 'gh'; Winget = 'GitHub.cli'; Brew = 'gh' }
   @{ Group = 'core'; Name = 'uv'; Command = 'uv'; Winget = 'astral-sh.uv'; Brew = 'uv' }
   @{ Group = 'core'; Name = 'Node.js LTS'; Command = 'node'; Winget = 'OpenJS.NodeJS.LTS'; Brew = 'node' }
   @{ Group = 'core'; Name = 'gitleaks'; Command = 'gitleaks'; Winget = 'Gitleaks.Gitleaks'; Brew = 'gitleaks' }
   @{ Group = 'core'; Name = 'Trivy'; Command = 'trivy'; Winget = 'AquaSecurity.Trivy'; Brew = 'trivy' }
   @{ Group = 'core'; Name = 'OSV-Scanner'; Command = 'osv-scanner'; Winget = 'Google.OSVScanner'; Brew = 'osv-scanner' }
   @{ Group = 'core'; Name = 'actionlint'; Command = 'actionlint'; Winget = 'rhysd.actionlint'; Brew = 'actionlint' }
   @{ Group = 'core'; Name = '1Password'; Command = '1Password'; MacApp = '/Applications/1Password.app'; Winget = 'AgileBits.1Password'; Brew = '1password'; Cask = $true }
   @{ Group = 'core'; Name = '1Password CLI'; Command = 'op'; Winget = 'AgileBits.1Password.CLI'; Brew = '1password-cli'; Cask = $true }
   @{ Group = 'dotnet'; Name = '.NET SDK 10'; Command = 'dotnet'; Winget = 'Microsoft.DotNet.SDK.10'; Brew = 'dotnet-sdk'; Cask = $true }
   @{ Group = 'java'; Name = 'Temurin JDK 21'; Command = 'java'; Winget = 'EclipseAdoptium.Temurin.21.JDK'; Brew = 'temurin@21'; Cask = $true }
   @{ Group = 'rust'; Name = 'rustup'; Command = 'rustup'; Winget = 'Rustlang.Rustup'; Brew = 'rustup' }
   @{ Group = 'go'; Name = 'Go'; Command = 'go'; Winget = 'GoLang.Go'; Brew = 'go' }
   @{ Group = 'swift'; Name = 'SwiftLint'; Command = 'swiftlint'; Winget = $null; Brew = 'swiftlint' }
   @{ Group = 'swift'; Name = 'swift-format'; Command = 'swift-format'; Winget = $null; Brew = 'swift-format' }
   @{ Group = 'shell'; Name = 'ShellCheck'; Command = 'shellcheck'; Winget = 'koalaman.shellcheck'; Brew = 'shellcheck' }
   @{ Group = 'shell'; Name = 'shfmt'; Command = 'shfmt'; Winget = 'mvdan.shfmt'; Brew = 'shfmt' }
   @{ Group = 'terraform'; Name = 'OpenTofu'; Command = 'tofu'; Winget = 'OpenTofu.Tofu'; Brew = 'opentofu' }
   @{ Group = 'terraform'; Name = 'TFLint'; Command = 'tflint'; Winget = 'TerraformLinters.tflint'; Brew = 'tflint' }
)

# Python tools installed with `uv tool install`, isolated from any project.
$script:UvTools = @('zizmor', 'pre-commit')

$script:Results = [System.Collections.Generic.List[object]]::new()



<#
.SYNOPSIS
   Records one check result and prints it as a colored line.
#>
function Add-Result
{
   param(
      [Parameter(Mandatory)] [ValidateSet('PASS', 'WARN', 'FAIL', 'INFO')] [string] $Status,
      [Parameter(Mandatory)] [string] $Item,
      [string] $Detail = ''
   )

   $script:Results.Add([pscustomobject]@{ Status = $Status; Item = $Item; Detail = $Detail })
   $color = @{ PASS = 'Green'; WARN = 'Yellow'; FAIL = 'Red'; INFO = 'Cyan' }[$Status]
   Write-Host ('{0,-5} {1,-34} {2}' -f $Status, $Item, $Detail) -ForegroundColor $color
}



<#
.SYNOPSIS
   Prints a section heading.
#>
function Write-Section
{
   param([Parameter(Mandatory)] [string] $Title)

   Write-Host ''
   Write-Host "== $Title ==" -ForegroundColor White
}



<#
.SYNOPSIS
   Reloads PATH from the registry so tools installed by winget are found in this session.
#>
function Import-MachinePath
{
   if ($IsWindows)
   {
      $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
      $user = [Environment]::GetEnvironmentVariable('Path', 'User')
      $env:Path = "$machine;$user;$env:LOCALAPPDATA\Microsoft\WinGet\Links"
   }
}



<#
.SYNOPSIS
   True when the named command is on PATH.
#>
function Test-Command
{
   param([Parameter(Mandatory)] [string] $Name)

   return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}



<#
.SYNOPSIS
   True when a catalog tool is present: its command on PATH, or its app bundle on macOS.
#>
function Test-ToolInstalled
{
   param([Parameter(Mandatory)] [hashtable] $Tool)

   if ($IsMacOS -and $Tool.ContainsKey('MacApp') -and (Test-Path -LiteralPath $Tool.MacApp))
   {
      return $true
   }
   return [bool] ($Tool.Command -and (Test-Command -Name $Tool.Command))
}



<#
.SYNOPSIS
   Installs one catalog entry with the platform's package manager, unless already present.
#>
function Install-CatalogTool
{
   [CmdletBinding(SupportsShouldProcess)]
   param([Parameter(Mandatory)] [hashtable] $Tool)

   if (Test-ToolInstalled -Tool $Tool)
   {
      Add-Result -Status PASS -Item $Tool.Name -Detail 'already installed'
      return
   }

   if ($IsWindows)
   {
      if (-not $Tool.Winget)
      {
         Add-Result -Status INFO -Item $Tool.Name -Detail 'not available on Windows; skipped'
         return
      }
      if ($PSCmdlet.ShouldProcess($Tool.Name, "winget install $($Tool.Winget)"))
      {
         & winget install --id $Tool.Winget --exact --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Host
         Import-MachinePath
      }
   }
   else
   {
      $cask = $Tool.ContainsKey('Cask') -and $Tool.Cask
      if ($cask -and $IsLinux)
      {
         Add-Result -Status WARN -Item $Tool.Name -Detail 'install manually on Linux (see standards/workstation.md)'
         return
      }
      $arguments = if ($cask) { @('install', '--cask', $Tool.Brew) } else { @('install', $Tool.Brew) }
      if ($PSCmdlet.ShouldProcess($Tool.Name, "brew $($arguments -join ' ')"))
      {
         & brew @arguments | Out-Host
      }
   }

   if ($WhatIfPreference)
   {
      return
   }
   if ($Tool.Command -and -not (Test-ToolInstalled -Tool $Tool))
   {
      Add-Result -Status FAIL -Item $Tool.Name -Detail 'install did not put it on PATH; open a new terminal and re-run'
      return
   }
   Add-Result -Status PASS -Item $Tool.Name -Detail 'installed'
}



<#
.SYNOPSIS
   Installs the uv-managed Python tools (zizmor, pre-commit), upgrading them if present.
#>
function Install-UvTool
{
   [CmdletBinding(SupportsShouldProcess)]
   param()

   if (-not (Test-Command -Name 'uv'))
   {
      Add-Result -Status FAIL -Item 'uv tools' -Detail 'uv is missing'
      return
   }
   foreach ($name in $script:UvTools)
   {
      if ($PSCmdlet.ShouldProcess($name, 'uv tool install --upgrade'))
      {
         & uv tool install --upgrade $name 2>&1 | Out-Null
         Add-Result -Status PASS -Item $name -Detail 'installed with uv'
      }
   }
}



<#
.SYNOPSIS
   Path of 1Password's SSH signing helper (op-ssh-sign) on this OS, or $null.
#>
function Get-OnePasswordSigner
{
   $candidates = if ($IsWindows)
   {
      # Direct installer (per user or per machine), then the Microsoft Store (MSIX) alias.
      @(
         "$env:LOCALAPPDATA\1Password\app\8\op-ssh-sign.exe"
         "$env:ProgramFiles\1Password\app\8\op-ssh-sign.exe"
         "$env:LOCALAPPDATA\Microsoft\WindowsApps\op-ssh-sign.exe"
      )
   }
   elseif ($IsMacOS)
   {
      @('/Applications/1Password.app/Contents/MacOS/op-ssh-sign')
   }
   else
   {
      @('/opt/1Password/op-ssh-sign')
   }
   return $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}



<#
.SYNOPSIS
   The socket of the 1Password SSH agent on macOS and Linux (Windows uses a named pipe).
#>
function Get-OnePasswordAgentSocket
{
   if ($IsMacOS)
   {
      return Join-Path $HOME 'Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'
   }
   if ($IsLinux)
   {
      return Join-Path $HOME '.1password/agent.sock'
   }
   return $null
}



<#
.SYNOPSIS
   Public keys the SSH agent offers, as objects with Line, Type, and Comment.
#>
function Get-AgentKey
{
   # Read-only: never inherit -WhatIf, which would leak into the cmdlets used here.
   $WhatIfPreference = $false

   $sshAdd = if ($IsWindows) { "$env:SystemRoot\System32\OpenSSH\ssh-add.exe" } else { 'ssh-add' }
   $socket = Get-OnePasswordAgentSocket
   if ($socket -and (Test-Path -LiteralPath $socket))
   {
      $env:SSH_AUTH_SOCK = $socket
   }

   $lines = & $sshAdd -L 2>$null
   if ($LASTEXITCODE -ne 0 -or -not $lines)
   {
      return @()
   }
   return @($lines | ForEach-Object {
         $parts = $_ -split ' ', 3
         [pscustomobject]@{ Line = "$($parts[0]) $($parts[1])"; Type = $parts[0]; Comment = if ($parts.Count -gt 2) { $parts[2] } else { '' } }
      })
}



<#
.SYNOPSIS
   Chooses the commit-signing key: by -SigningKey name, the only key, or by asking.
#>
function Select-SigningKey
{
   param(
      [Parameter(Mandatory)] [object[]] $Keys,
      [string] $Name
   )

   $candidates = @($Keys | Where-Object { $_.Type -like 'ssh-ed25519*' -or $_.Type -like 'ecdsa*' -or $_.Type -like 'sk-*' })
   if ($Name)
   {
      $candidates = @($candidates | Where-Object { $_.Comment -like "*$Name*" })
   }
   if ($candidates.Count -eq 1)
   {
      return $candidates[0]
   }
   if ($candidates.Count -eq 0)
   {
      return $null
   }

   Write-Host 'Several keys are available. Which one signs your commits?'
   for ($index = 0; $index -lt $candidates.Count; $index++)
   {
      Write-Host ('  [{0}] {1}' -f ($index + 1), $candidates[$index].Comment)
   }
   $choice = Read-Host 'Number'
   $number = 0
   if (-not [int]::TryParse($choice, [ref] $number) -or $number -lt 1 -or $number -gt $candidates.Count)
   {
      throw 'No signing key selected.'
   }
   return $candidates[$number - 1]
}



<#
.SYNOPSIS
   Points ssh (macOS/Linux) at the 1Password agent through ~/.ssh/config, keeping a backup.
#>
function Set-SshAgentConfig
{
   [CmdletBinding(SupportsShouldProcess)]
   param()

   $socket = Get-OnePasswordAgentSocket
   if (-not $socket)
   {
      return
   }
   $sshDirectory = Join-Path $HOME '.ssh'
   $config = Join-Path $sshDirectory 'config'
   $existing = if (Test-Path -LiteralPath $config) { Get-Content -LiteralPath $config -Raw } else { '' }
   if ($existing -match '(?im)^\s*IdentityAgent\s')
   {
      Add-Result -Status PASS -Item 'ssh IdentityAgent' -Detail 'already configured in ~/.ssh/config'
      return
   }
   if ($PSCmdlet.ShouldProcess($config, 'add Host * IdentityAgent for 1Password'))
   {
      New-Item -ItemType Directory -Force -Path $sshDirectory | Out-Null
      if ($existing)
      {
         Copy-Item -LiteralPath $config -Destination "$config.k22-backup" -Force
      }
      $block = "# Added by KofTwentyTwo Install-Workstation: SSH keys live in 1Password (K22-SEC-14).`nHost *`n   IdentityAgent `"$socket`"`n`n"
      Set-Content -LiteralPath $config -Value ($block + $existing) -NoNewline
      Add-Result -Status PASS -Item 'ssh IdentityAgent' -Detail 'pointed at the 1Password agent'
   }
}



<#
.SYNOPSIS
   Sets one global git configuration value, honoring -WhatIf.
#>
function Set-GitGlobal
{
   [CmdletBinding(SupportsShouldProcess)]
   param(
      [Parameter(Mandatory)] [string] $Key,
      [Parameter(Mandatory)] [string] $Value
   )

   if ($PSCmdlet.ShouldProcess("git config --global $Key", $Value))
   {
      & git config --global $Key $Value
   }
}



<#
.SYNOPSIS
   Configures git for KofTwentyTwo: SSH signing through 1Password, DCO alias, sane defaults.
#>
function Set-GitConfiguration
{
   [CmdletBinding(SupportsShouldProcess)]
   param(
      [string] $SigningKeyName,
      [switch] $Register
   )

   $email = & git config --global user.email
   $name = & git config --global user.name
   if (-not $email -or -not $name)
   {
      Add-Result -Status FAIL -Item 'git identity' -Detail 'set it first: git config --global user.name "..." ; git config --global user.email "..." (a verified GitHub email)'
      return
   }

   $signer = Get-OnePasswordSigner
   if (-not $signer)
   {
      Add-Result -Status FAIL -Item '1Password signer' -Detail 'op-ssh-sign not found: install 1Password and enable its SSH agent'
      return
   }

   $keys = @(Get-AgentKey)
   if ($keys.Count -eq 0)
   {
      Add-Result -Status FAIL -Item '1Password SSH agent' -Detail 'no keys offered: enable Settings > Developer > SSH agent and create an SSH key item'
      return
   }
   $key = Select-SigningKey -Keys $keys -Name $SigningKeyName
   if (-not $key)
   {
      Add-Result -Status FAIL -Item 'signing key' -Detail "no Ed25519/ECDSA key matching '$SigningKeyName' in the agent"
      return
   }

   Set-GitGlobal -Key 'gpg.format' -Value 'ssh'
   Set-GitGlobal -Key 'gpg.ssh.program' -Value ($signer -replace '\\', '/')
   Set-GitGlobal -Key 'user.signingkey' -Value $key.Line
   Set-GitGlobal -Key 'commit.gpgsign' -Value 'true'
   Set-GitGlobal -Key 'tag.gpgsign' -Value 'true'
   Set-GitGlobal -Key 'init.defaultBranch' -Value 'main'
   Set-GitGlobal -Key 'fetch.prune' -Value 'true'
   # Deliberately NOT set globally: core.autocrlf and pull.rebase. They change behavior in
   # every repository on the machine, including ones that are not KofTwentyTwo's; line
   # endings are governed per repository by .gitattributes (K22-REPO-03).
   Set-GitGlobal -Key 'alias.cs' -Value 'commit -s'
   if ($IsWindows)
   {
      # Windows OpenSSH talks to the 1Password agent's named pipe; Git's bundled ssh does not.
      Set-GitGlobal -Key 'core.sshCommand' -Value 'C:/Windows/System32/OpenSSH/ssh.exe'
   }

   # Lets `git log --show-signature` verify your own commits locally.
   $signersFile = Join-Path $HOME '.config/git/allowed_signers'
   if ($PSCmdlet.ShouldProcess($signersFile, 'write allowed signers'))
   {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $signersFile) | Out-Null
      Set-Content -LiteralPath $signersFile -Value "$email namespaces=`"git`" $($key.Line)"
      Set-GitGlobal -Key 'gpg.ssh.allowedSignersFile' -Value ($signersFile -replace '\\', '/')
   }
   Add-Result -Status PASS -Item 'git signing' -Detail "signs with '$($key.Comment)' via 1Password"

   if ($Register)
   {
      Register-GitHubSigningKey -Key $key
   }
}



<#
.SYNOPSIS
   Uploads the public signing key to GitHub as a signing key, if not already there.
#>
function Register-GitHubSigningKey
{
   [CmdletBinding(SupportsShouldProcess)]
   param([Parameter(Mandatory)] [object] $Key)

   $existing = & gh api user/ssh_signing_keys --jq '.[].key' 2>$null
   if ($LASTEXITCODE -eq 0 -and ($existing -contains $Key.Line))
   {
      Add-Result -Status PASS -Item 'GitHub signing key' -Detail 'already registered'
      return
   }
   if ($PSCmdlet.ShouldProcess('GitHub', 'add SSH signing key'))
   {
      & gh auth refresh --hostname github.com --scopes admin:ssh_signing_key | Out-Host
      $file = Join-Path ([System.IO.Path]::GetTempPath()) 'k22-signing-key.pub'
      Set-Content -LiteralPath $file -Value $Key.Line
      try
      {
         & gh ssh-key add $file --type signing --title "$([Environment]::MachineName) commit signing" | Out-Host
      }
      finally
      {
         Remove-Item -LiteralPath $file -Force
      }
      Add-Result -Status PASS -Item 'GitHub signing key' -Detail 'registered'
   }
}



<#
.SYNOPSIS
   Reports the machine security baseline of K22-SEC-20 and stray private keys (K22-SEC-14).
#>
function Test-SecurityBaseline
{
   # Read-only: never inherit -WhatIf, which would leak into the cmdlets used here.
   $WhatIfPreference = $false

   if ($IsWindows)
   {
      # Readable without elevation: 1 = BitLocker on, 3 = encrypting.
      $protection = (New-Object -ComObject Shell.Application).NameSpace("$env:SystemDrive\").Self.ExtendedProperty('System.Volume.BitLockerProtection')
      if ($protection -in 1, 3) { Add-Result -Status PASS -Item 'Disk encryption' -Detail 'BitLocker on system drive' }
      else { Add-Result -Status FAIL -Item 'Disk encryption' -Detail 'BitLocker is off on the system drive' }

      $profiles = @(Get-NetFirewallProfile -ErrorAction SilentlyContinue)
      if ($profiles.Count -gt 0 -and -not ($profiles | Where-Object { -not $_.Enabled })) { Add-Result -Status PASS -Item 'Firewall' -Detail 'all profiles enabled' }
      else { Add-Result -Status FAIL -Item 'Firewall' -Detail 'a Windows Firewall profile is disabled' }

      try
      {
         # CIM instead of Get-MpComputerStatus: importing the Defender module would pick up -WhatIf.
         $defender = Get-CimInstance -Namespace 'root/Microsoft/Windows/Defender' -ClassName 'MSFT_MpComputerStatus'
         if ($defender.RealTimeProtectionEnabled) { Add-Result -Status PASS -Item 'Malware protection' -Detail 'Defender real-time protection on' }
         else { Add-Result -Status WARN -Item 'Malware protection' -Detail 'Defender real-time protection off (fine if another product is active)' }
      }
      catch
      {
         Add-Result -Status WARN -Item 'Malware protection' -Detail 'could not read Defender status'
      }
   }
   elseif ($IsMacOS)
   {
      $fileVault = & fdesetup isactive 2>$null
      if ("$fileVault" -eq 'true') { Add-Result -Status PASS -Item 'Disk encryption' -Detail 'FileVault on' }
      else { Add-Result -Status FAIL -Item 'Disk encryption' -Detail 'FileVault is off' }

      $firewall = & /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>$null
      if ("$firewall" -match 'enabled') { Add-Result -Status PASS -Item 'Firewall' -Detail 'application firewall on' }
      else { Add-Result -Status FAIL -Item 'Firewall' -Detail 'application firewall is off' }
   }
   else
   {
      $crypt = & lsblk -o TYPE --noheadings 2>$null
      if ("$crypt" -match 'crypt') { Add-Result -Status PASS -Item 'Disk encryption' -Detail 'LUKS volume present' }
      else { Add-Result -Status WARN -Item 'Disk encryption' -Detail 'no LUKS volume found; confirm full-disk encryption' }
      Add-Result -Status INFO -Item 'Firewall' -Detail 'confirm ufw/firewalld is enabled'
   }

   $sshDirectory = Join-Path $HOME '.ssh'
   $privateKeys = @()
   if (Test-Path -LiteralPath $sshDirectory)
   {
      $privateKeys = @(Get-ChildItem -LiteralPath $sshDirectory -File | Where-Object {
            $_.Extension -ne '.pub' -and ((Get-Content -LiteralPath $_.FullName -TotalCount 1 -ErrorAction SilentlyContinue) -match 'PRIVATE KEY')
         })
   }
   if ($privateKeys.Count -eq 0) { Add-Result -Status PASS -Item 'Private keys on disk' -Detail 'none in ~/.ssh' }
   else { Add-Result -Status WARN -Item 'Private keys on disk' -Detail ("move into 1Password, then delete: {0}" -f (($privateKeys | ForEach-Object Name) -join ', ')) }
}



<#
.SYNOPSIS
   Reports whether git is configured for 1Password signing (used by -CheckOnly).
#>
function Test-GitConfiguration
{
   # Read-only: never inherit -WhatIf, which would leak into the cmdlets used here.
   $WhatIfPreference = $false

   $format = & git config --global gpg.format
   $program = & git config --global gpg.ssh.program
   $sign = & git config --global commit.gpgsign
   if ($format -eq 'ssh' -and $sign -eq 'true' -and "$program" -match 'op-ssh-sign')
   {
      Add-Result -Status PASS -Item 'git signing' -Detail 'SSH signing through 1Password'
   }
   elseif ($format -eq 'ssh' -and $sign -eq 'true')
   {
      Add-Result -Status WARN -Item 'git signing' -Detail "signs with SSH but not through op-ssh-sign ($program)"
   }
   else
   {
      Add-Result -Status FAIL -Item 'git signing' -Detail 'commits are not signed by default'
   }
   if (@(Get-AgentKey).Count -gt 0) { Add-Result -Status PASS -Item 'SSH agent' -Detail 'agent reachable and offering keys' }
   else { Add-Result -Status FAIL -Item 'SSH agent' -Detail 'no agent or no keys' }
}



#################################################################################
# Main                                                                          #
#################################################################################
$platform = if ($IsWindows) { 'Windows' } elseif ($IsMacOS) { 'macOS' } else { 'Linux' }
Write-Host "KofTwentyTwo workstation setup ($platform)" -ForegroundColor White
if (-not $IsWindows -and -not (Test-Command -Name 'brew'))
{
   throw 'Homebrew is required on macOS and Linux; run setup/bootstrap.sh, which installs it.'
}
if ($IsWindows -and -not (Test-Command -Name 'winget'))
{
   throw 'winget (App Installer) is required; install it from the Microsoft Store.'
}

$groups = @('core') + $Languages
Write-Section -Title 'Tools'
foreach ($tool in $script:Catalog | Where-Object { $_.Group -in $groups })
{
   if ($CheckOnly)
   {
      if (Test-ToolInstalled -Tool $tool) { Add-Result -Status PASS -Item $tool.Name -Detail 'installed' }
      else { Add-Result -Status FAIL -Item $tool.Name -Detail 'missing' }
   }
   else
   {
      Install-CatalogTool -Tool $tool
   }
}
if ($CheckOnly)
{
   foreach ($name in $script:UvTools)
   {
      if (Test-Command -Name $name) { Add-Result -Status PASS -Item $name -Detail 'installed' }
      else { Add-Result -Status FAIL -Item $name -Detail 'missing' }
   }
}
else
{
   Install-UvTool
   if ('shell' -in $Languages -and $PSCmdlet.ShouldProcess('PSScriptAnalyzer', 'Install-PSResource'))
   {
      Install-PSResource -Name PSScriptAnalyzer -Scope CurrentUser -TrustRepository -Quiet
      Add-Result -Status PASS -Item 'PSScriptAnalyzer' -Detail 'installed'
   }
}

Write-Section -Title 'Git and 1Password'
if ($CheckOnly)
{
   Test-GitConfiguration
}
elseif (-not $SkipGitConfig)
{
   Set-SshAgentConfig
   Set-GitConfiguration -SigningKeyName $SigningKey -Register:$RegisterSigningKey
}

Write-Section -Title 'Security baseline (K22-SEC-20)'
Test-SecurityBaseline

$failed = @($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count
$warned = @($script:Results | Where-Object { $_.Status -eq 'WARN' }).Count
Write-Host ''
Write-Host ("Done: {0} failed, {1} warnings." -f $failed, $warned) -ForegroundColor ($failed -gt 0 ? 'Red' : 'Green')
if (-not $CheckOnly -and $failed -eq 0)
{
   Write-Host 'Open a new terminal so newly installed tools are on PATH.'
}
exit ($failed -gt 0 ? 1 : 0)
