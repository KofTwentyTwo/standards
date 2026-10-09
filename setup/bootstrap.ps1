<#
.SYNOPSIS
   Windows bootstrap: installs PowerShell 7 if needed, then runs Install-Workstation.ps1.

.DESCRIPTION
   Runs in the Windows PowerShell 5.1 that ships with Windows, so it works on a brand-new
   machine. It downloads Install-Workstation.ps1 from the same ref of
   KofTwentyTwo/standards and runs it in PowerShell 7, passing through any arguments.

.PARAMETER Ref
   Branch, tag, or commit of KofTwentyTwo/standards to use. Pin a release tag for a
   reproducible setup.

.EXAMPLE
   & ([scriptblock]::Create((Invoke-RestMethod https://raw.githubusercontent.com/KofTwentyTwo/standards/main/setup/bootstrap.ps1))) -Languages dotnet
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive bootstrap: progress messages for the person running it.')]
[CmdletBinding()]
param(
   [string] $Ref = 'main',

   [Parameter(ValueFromRemainingArguments)]
   [object[]] $WorkstationArguments = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command -Name winget -ErrorAction SilentlyContinue))
{
   throw 'winget (App Installer) is required. Install "App Installer" from the Microsoft Store, then run this again.'
}

if (-not (Get-Command -Name pwsh -ErrorAction SilentlyContinue))
{
   Write-Host 'Installing PowerShell 7...'
   & winget install --id Microsoft.PowerShell --exact --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
   $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

$script = Join-Path ([System.IO.Path]::GetTempPath()) 'Install-Workstation.ps1'
$url = "https://raw.githubusercontent.com/KofTwentyTwo/standards/$Ref/setup/Install-Workstation.ps1"
Write-Host "Downloading $url"
Invoke-WebRequest -Uri $url -OutFile $script -UseBasicParsing

& pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File $script @WorkstationArguments
exit $LASTEXITCODE
