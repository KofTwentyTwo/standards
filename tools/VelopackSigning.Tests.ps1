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
