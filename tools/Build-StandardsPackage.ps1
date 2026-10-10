#Requires -Version 7.4
<#
.SYNOPSIS
Build versioned standards archives from a Git commit.
.DESCRIPTION
Uses git archive so untracked files and local edits cannot enter a release. Writes
ZIP, tar.gz, source manifest, release notes, and SHA256SUMS without overwriting output.
.PARAMETER Version
Stable semantic version matching the committed version.txt and release manifest.
.PARAMETER RepositoryPath
Local source repository; defaults to the parent directory of this script.
.PARAMETER Ref
Commit to package; defaults to HEAD.
.PARAMETER OutputPath
New output directory; defaults to artifacts/standards in the source repository.
.PARAMETER ChecklistUrl
Completed release checklist to link in the notes, when applicable.
#>
[CmdletBinding()]
param(
   [Parameter(Mandatory)]
   [ValidatePattern('^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')]
   [string] $Version,
   [string] $RepositoryPath = (Split-Path -Parent $PSScriptRoot),
   [ValidateNotNullOrEmpty()]
   [string] $Ref = 'HEAD',
   [string] $OutputPath,
   [AllowEmptyString()]
   [string] $ChecklistUrl = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$repository = (Resolve-Path -LiteralPath $RepositoryPath).Path
$commit = (git -C $repository rev-parse --verify "$Ref^{commit}").Trim()
$committedVersion = (git -C $repository show "${commit}:version.txt").Trim()
$releaseManifest = (git -C $repository show "${commit}:.release-please-manifest.json") | ConvertFrom-Json -AsHashtable
if($committedVersion -ne $Version -or $releaseManifest['.'] -ne $Version)
{
   throw "Version $Version does not match version.txt and the release manifest at $commit."
}

$changelog = (git -C $repository show "${commit}:CHANGELOG.md") -join "`n"
$escapedVersion = [regex]::Escape($Version)
$section = [regex]::Match($changelog, "(?ms)^## (?:\[$escapedVersion\](?:\([^\r\n]*\))?|$escapedVersion)(?=\s|$)[^\r\n]*\r?\n.*?(?=^## |\z)")
if(-not $section.Success)
{
   throw "CHANGELOG.md has no release notes for $Version at $commit."
}
$notes = $section.Value.Trim()
if($ChecklistUrl)
{
   if($ChecklistUrl -notmatch '^https://github\.com/[^/]+/[^/]+/issues/[1-9][0-9]*$')
   {
      throw 'ChecklistUrl must be a GitHub issue URL.'
   }
   $notes += "`n`nRelease checklist: $ChecklistUrl"
}

if(-not $OutputPath)
{
   $OutputPath = Join-Path $repository 'artifacts/standards'
}
$outputDirectory = [System.IO.Path]::GetFullPath($OutputPath)
if(Test-Path -LiteralPath $outputDirectory)
{
   throw "Output directory already exists: $outputDirectory. Choose a new directory."
}
New-Item -ItemType Directory -Path $outputDirectory | Out-Null

$name = "KofTwentyTwo-standards-$Version"
foreach($format in @('zip', 'tar.gz'))
{
   $archive = Join-Path $outputDirectory "$name.$format"
   git -C $repository archive "--format=$format" "--prefix=$name/" "--output=$archive" $commit
}

$manifest = [ordered]@{
   name       = 'KofTwentyTwo/standards'
   version    = $Version
   tag        = "v$Version"
   commit     = $commit
   repository = 'https://github.com/KofTwentyTwo/standards'
   licenses   = @('CC-BY-4.0 (documentation)', 'MIT (tooling)', 'Apache-2.0 (Kingsrook files; see NOTICE)')
}
$utf8 = [System.Text.UTF8Encoding]::new($false)
$manifestText = ($manifest | ConvertTo-Json -Depth 4).Replace("`r`n", "`n") + "`n"
[System.IO.File]::WriteAllText((Join-Path $outputDirectory "$name.manifest.json"), $manifestText, $utf8)
[System.IO.File]::WriteAllText((Join-Path $outputDirectory "$name.notes.md"), $notes.Replace("`r`n", "`n") + "`n", $utf8)
$checksums = foreach($file in (Get-ChildItem -LiteralPath $outputDirectory -File | Sort-Object -Property Name))
{
   $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
   "$hash  $($file.Name)"
}
[System.IO.File]::WriteAllText((Join-Path $outputDirectory 'SHA256SUMS'), ($checksums -join "`n") + "`n", $utf8)
Write-Output "Built $name from $commit in $outputDirectory"
