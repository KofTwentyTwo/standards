#Requires -Version 7.4
# Copyright (c) 2026 James Maes
# SPDX-License-Identifier: MIT

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

BeforeAll `
{
   $lines = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../.github/workflows/release-velopack.yml')
   $start = [Array]::IndexOf($lines, "          @'")
   $end = $start + 1
   while($end -lt $lines.Count -and -not $lines[$end].StartsWith("          '@ | Set-Content")) { $end++ }
   if($start -lt 0 -or $end -ge $lines.Count) { throw 'Cannot locate the actual Velopack signing wrapper.' }
   $script:Wrapper = Join-Path $TestDrive 'sign-one.ps1'
   [IO.File]::WriteAllLines($script:Wrapper, @($lines[($start + 1)..($end - 1)] | ForEach-Object { $_.Substring(10) }))
   $dependencyStart = [Array]::IndexOf($lines, '      - name: Prepare pinned Artifact Signing CLI dependency')
   if($dependencyStart -lt 0) { throw 'Cannot locate the actual signing dependency bootstrap.' }
   $dependencyStart += 4
   $dependencyEnd = $dependencyStart
   while($dependencyEnd -lt $lines.Count -and $lines[$dependencyEnd].StartsWith('          ')) { $dependencyEnd++ }
   $script:Bootstrap = Join-Path $TestDrive 'sign-dependency.ps1'
   # GitHub's default pwsh shell prepends this statement to every inline run body.
   [IO.File]::WriteAllLines($script:Bootstrap, @('$ErrorActionPreference = "stop"') + @($lines[$dependencyStart..($dependencyEnd - 1)] | ForEach-Object { $_.Substring(10) }))
   $script:OldTool = $env:K22_VPK_SIGN_TOOL
   $env:K22_VPK_SIGN_TOOL = 'Invoke-WrapperTool'

   <#
   .SYNOPSIS
   Simulates signing and verification without using credentials.
   #>
   function Invoke-WrapperTool
   {
      [CmdletBinding()]
      param([Parameter(ValueFromRemainingArguments)] [string[]] $ToolArguments)

      $ToolCalls.Add($ToolArguments)
      $global:LASTEXITCODE = if($ToolArguments[0] -eq 'sign') { $SignExit } else { $VerifyExit }
   }
}

Describe 'The actual Artifact Signing dependency bootstrap' `
{
   BeforeEach `
   {
      $script:InstallRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
      $script:PackageDirectory = Join-Path $script:InstallRoot 'downloads'
      [void][IO.Directory]::CreateDirectory($script:PackageDirectory)
      $script:Destination = Join-Path $script:InstallRoot 'ArtifactSigning/sign/sign.0.9.1-beta.26227.3'
      Mock Invoke-WebRequest `
      {
         $fixture = Join-Path (Split-Path -Parent $OutFile) 'fixture'
         [void][IO.Directory]::CreateDirectory((Join-Path $fixture 'tools/net8.0/any'))
         [IO.File]::WriteAllText((Join-Path $fixture 'tools/net8.0/any/sign.dll'), 'fixture')
         [IO.Compression.ZipFile]::CreateFromDirectory($fixture, $OutFile)
      }
      Mock Get-FileHash { [pscustomobject]@{ Hash = '34FD0D4AEABDBC363A48883881865B4DD65E6C11BA916028082FA23F3E1B1BA1' } }
      Mock dotnet { $global:LASTEXITCODE = 0 }
   }

   It 'stages the verified tool where the official action finds it' `
   {
      & $script:Bootstrap -InstallRoot $script:InstallRoot -PackageDirectory $script:PackageDirectory
      Get-Content -LiteralPath (Join-Path $script:Destination 'tools/net8.0/any/sign.dll') | Should -Be 'fixture'
      Should -Invoke dotnet -Exactly 1
   }

   It 'rejects a changed download before verification or extraction' `
   {
      Mock Get-FileHash { [pscustomobject]@{ Hash = 'bad' } }
      { & $script:Bootstrap -InstallRoot $script:InstallRoot -PackageDirectory $script:PackageDirectory } | Should -Throw '*checksum mismatch*'
      Test-Path -LiteralPath $script:Destination | Should -BeFalse
      Should -Invoke dotnet -Exactly 0
   }

   It 'rejects an invalid NuGet signature before extraction' `
   {
      Mock dotnet { $global:LASTEXITCODE = 1 }
      { & $script:Bootstrap -InstallRoot $script:InstallRoot -PackageDirectory $script:PackageDirectory } | Should -Throw '*signature verification failed*'
      Test-Path -LiteralPath $script:Destination | Should -BeFalse
   }

   It 'preserves a preexisting dependency directory' `
   {
      [void][IO.Directory]::CreateDirectory($script:Destination)
      $marker = Join-Path $script:Destination 'marker.txt'
      [IO.File]::WriteAllText($marker, 'preserve')
      { & $script:Bootstrap -InstallRoot $script:InstallRoot -PackageDirectory $script:PackageDirectory } | Should -Throw '*already exists*'
      Get-Content -LiteralPath $marker | Should -Be 'preserve'
      Should -Invoke Invoke-WebRequest -Exactly 0
   }

   It 'rejects a package without the expected executable' `
   {
      Mock Invoke-WebRequest `
      {
         $emptyFixture = Join-Path (Split-Path -Parent $OutFile) 'empty'
         [void][IO.Directory]::CreateDirectory($emptyFixture)
         [IO.Compression.ZipFile]::CreateFromDirectory($emptyFixture, $OutFile)
      }
      { & $script:Bootstrap -InstallRoot $script:InstallRoot -PackageDirectory $script:PackageDirectory } | Should -Throw '*missing its executable*'
   }
}

AfterAll `
{
   $env:K22_VPK_SIGN_TOOL = $script:OldTool
}

Describe 'The actual Velopack signing wrapper' `
{
   BeforeEach `
   {
      $script:ToolCalls = [Collections.Generic.List[object]]::new()
      $script:SignExit = 0
      $script:VerifyExit = 0
      Mock Get-AuthenticodeSignature { [pscustomobject]@{ Status = 'NotSigned' } }
   }

   It 'preserves a valid existing signature without signing again' `
   {
      Mock Get-AuthenticodeSignature { [pscustomobject]@{ Status = 'Valid' } }
      & $script:Wrapper -File 'a file.dll'
      $script:ToolCalls.Count | Should -Be 0
   }

   It 'refuses an invalid existing signature' `
   {
      Mock Get-AuthenticodeSignature { [pscustomobject]@{ Status = 'HashMismatch' } }
      { & $script:Wrapper -File 'a file.dll' } | Should -Throw '*invalid signature*'
      $script:ToolCalls.Count | Should -Be 0
   }

   It 'stops on signing failure before verification' `
   {
      $script:SignExit = 1
      { & $script:Wrapper -File 'a file.dll' } | Should -Throw '*Artifact Signing failed*'
      $script:ToolCalls.Count | Should -Be 1
   }

   It 'stops when signature verification fails' `
   {
      $script:VerifyExit = 1
      { & $script:Wrapper -File 'a file.dll' } | Should -Throw '*Signature verification failed*'
      $script:ToolCalls.Count | Should -Be 2
   }

   It 'uses SHA256, RFC3161 timestamping and all-signature trust verification' `
   {
      & $script:Wrapper -File 'a file.dll'
      $script:ToolCalls.Count | Should -Be 2
      ($script:ToolCalls[0] -join ' ') | Should -BeLike 'sign /fd SHA256 /tr http://timestamp.acs.microsoft.com /td SHA256* a file.dll'
      ($script:ToolCalls[1] -join ' ') | Should -Be 'verify /pa /all /v a file.dll'
   }
}
