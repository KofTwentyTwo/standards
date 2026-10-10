#Requires -Version 7.4
<#
.SYNOPSIS
Exercise standards packaging with an isolated local Git fixture.
.DESCRIPTION
Checks committed content, hidden files, both archive formats, determinism, hashes,
version validation, release notes, and refusal to overwrite existing output.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

<#
.SYNOPSIS
Fail a behavioral assertion with a descriptive message.
#>
function Test-Condition
{
   param([bool] $Condition, [string] $Message)
   if(-not $Condition) { throw "FAIL: $Message" }
   Write-Output "PASS: $Message"
}



<#
.SYNOPSIS
Verify an operation refuses invalid input for the expected reason.
#>
function Test-Exception
{
   param([scriptblock] $Operation, [string] $Pattern)
   $failure = $null
   try { & $Operation | Out-Null }
   catch { $failure = $_.Exception.Message }
   Test-Condition ($null -ne $failure -and $failure -match $Pattern) "rejects $Pattern"
}

$builder = Join-Path $PSScriptRoot 'Build-StandardsPackage.ps1'
$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) "standards-package-$([guid]::NewGuid().ToString('N'))"
$source = Join-Path $fixtureRoot 'source'
New-Item -ItemType Directory -Path $source | Out-Null
git init --quiet $source
git -C $source config core.autocrlf false
git -C $source config core.hooksPath /dev/null
Set-Content -LiteralPath (Join-Path $source 'version.txt') -Value '1.2.3'
Set-Content -LiteralPath (Join-Path $source '.release-please-manifest.json') -Value '{".":"1.2.3"}'
Set-Content -LiteralPath (Join-Path $source '.editorconfig') -Value 'root = true'
Set-Content -LiteralPath (Join-Path $source 'README.md') -Value 'committed content'
Set-Content -LiteralPath (Join-Path $source 'CHANGELOG.md') -Value @'
# Changelog

## [1.2.4](https://example.com/next) (2026-10-11)

Future notes.

## [1.2.3](https://example.com/current) (2026-10-10)

### Security

Current notes.

## 1.2.2

Older notes.
'@
git -C $source add -- .
git -C $source -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m 'test: packaging fixture'

Set-Content -LiteralPath (Join-Path $source 'README.md') -Value 'uncommitted content'
Set-Content -LiteralPath (Join-Path $source 'local-only.txt') -Value 'untracked content'
$first = Join-Path $fixtureRoot 'first'
$second = Join-Path $fixtureRoot 'second'
$checklist = 'https://github.com/KofTwentyTwo/standards/issues/123'
& $builder -Version '1.2.3' -RepositoryPath $source -OutputPath $first -ChecklistUrl $checklist
& $builder -Version '1.2.3' -RepositoryPath $source -OutputPath $second -ChecklistUrl $checklist

$prefix = 'KofTwentyTwo-standards-1.2.3'
$zip = [System.IO.Compression.ZipFile]::OpenRead((Join-Path $first "$prefix.zip"))
try
{
   $names = @($zip.Entries.FullName)
   Test-Condition ($names -contains "$prefix/.editorconfig") 'ZIP preserves hidden configuration files'
   Test-Condition (-not ($names -match '/(?:\.git/|local-only\.txt$)')) 'ZIP excludes Git metadata and untracked files'
   $reader = [System.IO.StreamReader]::new($zip.GetEntry("$prefix/README.md").Open())
   try { Test-Condition ($reader.ReadToEnd().Trim() -eq 'committed content') 'ZIP contains committed content despite local edits' }
   finally { $reader.Dispose() }
}
finally { $zip.Dispose() }

$extracted = Join-Path $fixtureRoot 'extracted'
New-Item -ItemType Directory -Path $extracted | Out-Null
tar -xzf (Join-Path $first "$prefix.tar.gz") -C $extracted
Test-Condition ((Get-Content -LiteralPath (Join-Path $extracted "$prefix/README.md") -Raw).Trim() -eq 'committed content') 'tar.gz contains committed content'
Test-Condition (Test-Path -LiteralPath (Join-Path $extracted "$prefix/.editorconfig")) 'tar.gz preserves hidden configuration files'
$manifest = Get-Content -LiteralPath (Join-Path $first "$prefix.manifest.json") -Raw | ConvertFrom-Json
Test-Condition ($manifest.version -eq '1.2.3' -and $manifest.commit -eq (git -C $source rev-parse HEAD)) 'manifest identifies version and exact source commit'
$notes = Get-Content -LiteralPath (Join-Path $first "$prefix.notes.md") -Raw
Test-Condition ($notes -match 'Current notes' -and $notes -notmatch 'Older notes|Future notes' -and $notes.Contains($checklist)) 'notes contain only this release and its checklist'
foreach($file in (Get-ChildItem -LiteralPath $first -File))
{
   Test-Condition ((Get-FileHash -LiteralPath $file.FullName).Hash -eq (Get-FileHash -LiteralPath (Join-Path $second $file.Name)).Hash) "$($file.Name) is reproducible"
}
$checksums = @(Get-Content -LiteralPath (Join-Path $first 'SHA256SUMS'))
Test-Condition ($checksums.Count -eq 4) 'checksums cover every asset except the checksum file itself'
foreach($line in $checksums)
{
   $hash, $fileName = $line -split '  ', 2
   Test-Condition ($hash -eq (Get-FileHash -LiteralPath (Join-Path $first $fileName)).Hash.ToLowerInvariant()) "$fileName matches its checksum"
}
Test-Exception { & $builder -Version '1.2.4' -RepositoryPath $source -OutputPath (Join-Path $fixtureRoot 'mismatch') } 'does not match'
Test-Exception { & $builder -Version '01.2.3' -RepositoryPath $source } 'ValidatePattern|validation|pattern'
Test-Exception { & $builder -Version '1.2.3' -RepositoryPath $source -OutputPath $first } 'already exists'
Test-Exception { & $builder -Version '1.2.3' -RepositoryPath $source -OutputPath (Join-Path $fixtureRoot 'invalid-url') -ChecklistUrl 'http://example.com/123' } 'GitHub issue URL'
Set-Content -LiteralPath (Join-Path $source 'CHANGELOG.md') -Value '# Changelog without release notes'
git -C $source add -- CHANGELOG.md
git -C $source -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m 'test: missing release notes fixture'
Test-Exception { & $builder -Version '1.2.3' -RepositoryPath $source -OutputPath (Join-Path $fixtureRoot 'missing-notes') } 'no release notes'
Write-Output "All standards package tests passed. Fixture: $fixtureRoot"
