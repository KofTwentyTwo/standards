#Requires -Version 7.2
<#
.SYNOPSIS
    Checks a repository against the KofTwentyTwo repository and CI/CD standards.

.DESCRIPTION
    Evaluates automatable requirements in standards/repository.md (K22-REPO-*),
    standards/ci-cd.md (K22-CI-*), and the K22-TEST-25 fuzzing scope record, printing
    one row per requirement:

        PASS      the requirement is met
        FAIL      a MUST is not met (or a SHOULD, reported as WARN instead)
        WARN      a SHOULD is not met, or a MUST needs a human look
        EXCEPTED  the requirement fails but an open exception in
                  exceptions/register.md covers this repository
        N/A       does not apply to this repository
        UNKNOWN   could not be determined (missing token scope, API unavailable,
                  tool not installed); never fails the run but should be resolved
        REVIEW    verified by a person, not by this tool

    Static checks read a local clone (-LocalPath) or, without one, the repository
    contents through the GitHub API. Settings checks call the GitHub API through the
    `gh` CLI with your login; they are read-only. Some settings (rulesets' bypass
    actors, Actions permissions, secrets) need admin access to the repository; when
    the token cannot read them the row is UNKNOWN.

    Exit code: 1 when any MUST requirement fails (EXCEPTED and UNKNOWN do not count),
    otherwise 0.

.PARAMETER Repository
    owner/name on GitHub. Required unless -StaticOnly is used with -LocalPath.

.PARAMETER LocalPath
    Path to a local clone. Static checks use it instead of the API.

.PARAMETER StaticOnly
    Skip every GitHub API call; check only files. Used by CI without admin scope.

.PARAMETER StandardsPath
    Root of the KofTwentyTwo/standards checkout, for the exception register and
    MAINTAINERS.md. Defaults to the repository containing this script.

.PARAMETER Json
    Emit results as JSON instead of a table.

.PARAMETER SelfTest
    Run the checker's own unit tests and exit.

.PARAMETER LoadHelpers
    Load pure parser helpers for the fuzz harness without checking a repository.

.EXAMPLE
    ./tools/Test-RepoConformance.ps1 -Repository KofTwentyTwo/AppKit -LocalPath ../AppKit

.EXAMPLE
    ./tools/Test-RepoConformance.ps1 -LocalPath . -StaticOnly
#>
[CmdletBinding()]
param(
    [string] $Repository,
    [string] $LocalPath,
    [switch] $StaticOnly,
    [string] $StandardsPath = (Split-Path -Parent $PSScriptRoot),
    [switch] $Json,
    [switch] $SelfTest,
    [switch] $LoadHelpers
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------------
# Requirement catalog: ID -> level. Kept in step with standards/repository.md and
# standards/ci-cd.md; the self-test fails if an ID is evaluated but not listed here.
# ---------------------------------------------------------------------------------
$script:Levels = [ordered]@{
    'K22-REPO-01' = 'MUST';   'K22-REPO-02' = 'MUST';   'K22-REPO-03' = 'MUST'
    'K22-REPO-04' = 'MUST';   'K22-REPO-05' = 'MUST';   'K22-REPO-06' = 'MUST'
    'K22-REPO-07' = 'MUST';   'K22-REPO-08' = 'MUST';   'K22-REPO-09' = 'MUST'
    'K22-REPO-10' = 'SHOULD'; 'K22-REPO-11' = 'SHOULD'; 'K22-REPO-12' = 'MUST'
    'K22-TEST-25' = 'MUST';   'K22-REPO-20' = 'MUST'
    'K22-REPO-21' = 'MUST';   'K22-REPO-22' = 'MUST';   'K22-REPO-30' = 'MUST'
    'K22-REPO-31' = 'MUST';   'K22-REPO-32' = 'SHOULD'; 'K22-REPO-40' = 'MUST'
    'K22-REPO-41' = 'SHOULD'; 'K22-REPO-42' = 'MUST'
    'K22-CI-01'   = 'MUST';   'K22-CI-02'   = 'MUST';   'K22-CI-03'   = 'MUST'
    'K22-CI-10'   = 'MUST';   'K22-CI-11'   = 'MUST';   'K22-CI-12'   = 'MUST'
    'K22-CI-13'   = 'MUST';   'K22-CI-14'   = 'MUST';   'K22-CI-15'   = 'MUST'
    'K22-CI-16'   = 'MUST';   'K22-CI-17'   = 'MUST';   'K22-CI-18'   = 'SHOULD'
    'K22-CI-20'   = 'MUST';   'K22-CI-21'   = 'MUST';   'K22-CI-22'   = 'MUST'
    'K22-CI-23'   = 'MUST';   'K22-CI-24'   = 'SHOULD'; 'K22-CI-30'   = 'MUST'
    'K22-CI-31'   = 'MUST'
}

# Status contexts the protect-main ruleset must require (K22-CI-01).
$script:RequiredContexts = @(
    'pr / title', 'pr / dco', 'pr / dependency-review',
    'security / secrets', 'security / sca', 'security / workflows'
)
$script:RequiredContextPrefixes = @('codeql / analyze')

$script:Results = [System.Collections.Generic.List[object]]::new()

function Add-Result
{
    param([string] $Id, [string] $Status, [string] $Detail, [string[]] $Aspects = @())
    if (-not $script:Levels.Contains($Id)) { throw "Unknown requirement ID $Id" }
    $level = $script:Levels[$Id]
    # A failing SHOULD is a warning, never a failure.
    if ($Status -eq 'FAIL' -and $level -eq 'SHOULD') { $Status = 'WARN' }
    # Aspects name the distinct problems behind a FAIL, so an exception scoped to one
    # aspect ("K22-REPO-20 (approval count)") cannot hide the others.
    $script:Results.Add([pscustomobject]@{ Id = $Id; Level = $level; Status = $Status; Detail = $Detail; Aspects = @($Aspects) })
}

# =================================================================================
# Pure helpers (covered by -SelfTest)
# =================================================================================

# Classifies one `uses:` value. Returns PINNED, LOCAL, or a reason it is not pinned.
function Get-UsesPinState
{
    param([string] $Uses)
    $value = $Uses.Trim().Trim('"', "'")
    if ($value.StartsWith('./')) { return 'LOCAL' }
    if ($value.StartsWith('docker://'))
    {
        if ($value -match '@sha256:[0-9a-f]{64}$') { return 'PINNED' }
        return 'image not pinned by digest'
    }
    if ($value -match '^[^@\s]+@([0-9a-f]{40})$') { return 'PINNED' }
    if ($value -match '@') { return 'ref is not a full commit SHA' }
    return 'no ref'
}

# Returns every `uses:` value in workflow text, with line numbers.
function Get-WorkflowUses
{
    param([string] $Text)
    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++)
    {
        if ($lines[$i] -match '^\s*(?:-\s+)?uses:\s*([^\s#]+)')
        {
            [pscustomobject]@{ Line = $i + 1; Uses = $Matches[1] }
        }
    }
}

# Returns the top-level `permissions:` value as text ('' when absent).
function Get-TopLevelPermissions
{
    param([string] $Text)
    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++)
    {
        if ($lines[$i] -match '^permissions:\s*(.*?)\s*(#.*)?$')
        {
            $inline = $Matches[1]
            if ($inline) { return $inline }
            $block = for ($j = $i + 1; $j -lt $lines.Count -and $lines[$j] -match '^\s+\S'; $j++) { $lines[$j].Trim() }
            return ($block -join '; ')
        }
    }
    return ''
}

# Returns `run:` script bodies with their starting line numbers.
function Get-RunBlocks
{
    param([string] $Text)
    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++)
    {
        if ($lines[$i] -match '^(\s*)(?:-\s+)?run:\s*(.*)$')
        {
            $indent = $Matches[1].Length
            $rest = $Matches[2]
            if ($rest -and $rest -notmatch '^[|>](?:[1-9][+-]?|[+-][1-9]?|[+-]?)\s*(?:#.*)?$')
            {
                [pscustomobject]@{ Line = $i + 1; Body = $rest }
                continue
            }
            $body = [System.Collections.Generic.List[string]]::new()
            for ($j = $i + 1; $j -lt $lines.Count; $j++)
            {
                $line = $lines[$j]
                if ($line.Trim() -eq '') { $body.Add(''); continue }
                if (($line.Length - $line.TrimStart().Length) -le $indent) { break }
                $body.Add($line)
            }
            [pscustomobject]@{ Line = $i + 1; Body = ($body -join "`n") }
        }
    }
}

# Attacker-controllable expressions that must never be interpolated into run:.
$script:UntrustedExpressions = @(
    'github\.event\.(pull_request|issue|comment|review|review_comment|discussion|pages|head_commit|commits|workflow_run)\.',
    'github\.event\.(pull_request|issue)\.(title|body)',
    'github\.head_ref',
    'inputs\.[A-Za-z0-9_-]+'
)

# Returns template-injection findings: untrusted ${{ }} inside run: bodies.
# Workflow inputs are flagged only for workflow_dispatch/issue-driven workflows,
# so callers pass -IncludeInputs when the workflow is triggerable by others.
function Find-TemplateInjection
{
    param([string] $Text, [switch] $IncludeInputs)
    $patterns = if ($IncludeInputs) { $script:UntrustedExpressions } else { $script:UntrustedExpressions[0..2] }
    foreach ($block in Get-RunBlocks -Text $Text)
    {
        foreach ($m in [regex]::Matches($block.Body, '\$\{\{(.*?)\}\}'))
        {
            $expr = $m.Groups[1].Value
            foreach ($p in $patterns)
            {
                if ($expr -match $p)
                {
                    [pscustomobject]@{ Line = $block.Line; Expression = $expr.Trim() }
                    break
                }
            }
        }
    }
}

# Returns checkout steps (line numbers) that do not set persist-credentials: false.
function Find-PersistedCheckout
{
    param([string] $Text)
    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++)
    {
        if ($lines[$i] -match '^(\s*)(-\s+)?uses:\s*["'']?actions/checkout@')
        {
            $stepIndent = $Matches[1].Length
            $ok = $false
            for ($j = $i + 1; $j -lt $lines.Count; $j++)
            {
                $line = $lines[$j]
                if ($line -match '^\s*-\s' -and ($line.Length - $line.TrimStart().Length) -le $stepIndent) { break }
                if ($line.Trim() -ne '' -and ($line.Length - $line.TrimStart().Length) -lt $stepIndent) { break }
                if ($line -match 'persist-credentials:\s*false') { $ok = $true; break }
            }
            if (-not $ok) { $i + 1 }
        }
    }
}

# Parses the summary table of exceptions/register.md.
function Read-ExceptionRegister
{
    param([string] $Text)
    foreach ($line in ($Text -split "`r?`n"))
    {
        if ($line -notmatch '^\|\s*\[?(EX-\d{4})') { continue }
        $cells = ($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -lt 4) { continue }
        $id = $Matches[1]
        $qualifiers = @{}
        foreach ($m in [regex]::Matches($cells[2], '(K22-[A-Z]+(?:-[A-Z]+)?-\d{2})(?:\s*\(([^)]*)\))?'))
        {
            $qualifiers[$m.Groups[1].Value] = $m.Groups[2].Value.Trim()
        }
        [pscustomobject]@{
            Id           = $id
            Status       = $cells[1]
            Requirements = @($qualifiers.Keys)
            Qualifiers   = $qualifiers
            Scope        = $cells[3]
            Expires      = if ($cells.Count -ge 5) { $cells[4] } else { '' }
        }
    }
}

# Returns the open exception covering a requirement for a repository, or $null.
function Find-Exception
{
    param([object[]] $Register, [string] $RequirementId, [string] $RepositoryName, [string[]] $Aspects = @(), [datetime] $Today = [datetime]::UtcNow.Date)
    foreach ($ex in $Register)
    {
        if ($ex.Status -notmatch '^Open$') { continue }
        # Review dates are not expiry dates. Enforce an explicit ISO expiry or an
        # "at the latest" deadline; condition-only expiry still needs human review.
        if ($ex.Expires -match '(?i)(?:^|at (?:the )?latest\s+)(\d{4}-\d{2}-\d{2})')
        {
            $deadline = [datetime]::MinValue
            if (-not [datetime]::TryParseExact($Matches[1], 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref] $deadline)) { continue }
            if ($Today.Date -ge $deadline.Date) { continue }
        }
        if ($ex.Requirements -notcontains $RequirementId) { continue }
        # A qualified exception covers a failure only when every failing aspect is
        # the qualified one.
        $qualifier = $ex.Qualifiers[$RequirementId]
        if ($qualifier)
        {
            $other = @($Aspects | Where-Object { $_ -ine $qualifier })
            if ($Aspects.Count -eq 0 -or $other.Count -gt 0) { continue }
        }
        $short = if ($RepositoryName) { ($RepositoryName -split '/')[-1] } else { '' }
        if ($ex.Scope -match '(?i)^all repositories' -or
            ($RepositoryName -and $ex.Scope -match "(?i)(^|[\s,(])$([regex]::Escape($RepositoryName))($|[\s,)])") -or
            ($short -and $ex.Scope -match "(?i)(^|[\s,(])$([regex]::Escape($short))($|[\s,)])"))
        {
            return $ex
        }
    }
    return $null
}

<#
.SYNOPSIS
Validate declared assurance evidence without executing commands or claiming certification.
#>
function Get-AssuranceCheck
{
   param([string] $Text, [string[]] $Paths, [hashtable] $Workflows, [string] $Readme)
   try
   {
      $record = ConvertFrom-Json -InputObject $Text -AsHashtable -ErrorAction Stop
      if ($record -isnot [System.Collections.IDictionary] -or $record['schemaVersion'] -isnot [long] -or $record['schemaVersion'] -ne 1) { throw 'unsupported schema' }
   }
   catch
   {
      foreach ($id in 'K22-REPO-12', 'K22-TEST-25')
      {
         [pscustomobject]@{ Id = $id; Status = 'FAIL'; Detail = 'missing or invalid docs/security/assurance.json (schemaVersion 1)'; Aspects = @('record') }
      }
      return
   }
   foreach ($pair in @(@('badge', 'K22-REPO-12'), @('fuzzing', 'K22-TEST-25')))
   {
      $kind, $id = $pair
      $entry = $record[$kind]
      $status, $detail, $aspect = 'FAIL', 'invalid assurance scope, rationale or evidence path', 'record'
      if ($entry -is [System.Collections.IDictionary] -and
         $entry['applicability'] -in @('required', 'not-applicable') -and
         $entry['reason'] -is [string] -and -not [string]::IsNullOrWhiteSpace($entry['reason']) -and
         $entry['evidence'] -is [string] -and $entry['evidence'] -cmatch '^docs/security/[A-Za-z0-9._/-]+\.md$' -and
         $entry['evidence'] -notmatch '(^|/)\.\.?(/|$)' -and $Paths -ccontains $entry['evidence'])
      {
         if ($entry['applicability'] -eq 'not-applicable')
         {
            $status, $detail = 'REVIEW', "$kind scope declared not applicable; verify rationale and input/public-Product scope in $($entry.evidence)"
         }
         elseif ($kind -eq 'badge')
         {
            $aspect = 'enrollment'
            $detail = 'badge enrollment missing; register this repository or obtain a dated enrollment exception'
            if ($entry['projectUrl'] -is [string] -and $entry['projectUrl'] -cmatch '^https://www\.bestpractices\.dev/(?:en/)?projects/([1-9][0-9]*)/?$')
            {
               $projectId = $Matches[1]
               $badgePattern = '\[!\[[^\]]*\]\(https://www\.bestpractices\.dev/projects/' + $projectId + '/badge\)\]\(https://www\.bestpractices\.dev/(?:en/)?projects/' + $projectId + '/?\)'
               if ($Readme -cmatch $badgePattern)
               {
                  $status, $detail = 'REVIEW', "badge linked; verify $($entry.projectUrl) belongs to this repository, current answers and 90-day review in $($entry.evidence)"
               }
               else { $detail = 'README lacks the actual linked badge matching the declared project ID' }
            }
         }
         else
         {
            $aspect = 'fuzzing'
            $targets = @($entry['targets'])
            $validTargets = $targets.Count -gt 0 -and @($targets | Where-Object {
                  $_ -isnot [string] -or $_ -match '(^[/\\]|^[A-Za-z]:|(^|[/\\])\.\.?([/\\]|$))' -or $Paths -cnotcontains $_
               }).Count -eq 0
            $validWorkflow = $entry['workflow'] -is [string] -and $entry['workflow'] -cmatch '^\.github/workflows/[^/]+\.ya?ml$' -and $Workflows.ContainsKey($entry['workflow'])
            $validCommand = $entry['command'] -is [string] -and -not [string]::IsNullOrWhiteSpace($entry['command']) -and $entry['command'] -notmatch '[\r\n]'
            $runs = if ($validWorkflow) { @(Get-RunBlocks $Workflows[$entry['workflow']] | ForEach-Object Body) -join "`n" } else { '' }
            $commandInRun = $validCommand -and $runs -cmatch ('(?m)^\s*' + [regex]::Escape($entry['command'].Trim()) + '(?:\s|$)')
            if ($validTargets -and $validWorkflow -and $commandInRun)
            {
               $status, $detail = 'REVIEW', "fuzz targets and run command found; verify required PR/main gate, weekly/release budgets, properties and replay in $($entry.evidence)"
            }
            else { $detail = 'declared fuzz targets must exist and the command must begin a run line in the declared workflow' }
         }
      }
      [pscustomobject]@{ Id = $id; Status = $status; Detail = $detail; Aspects = @($aspect) }
   }
}

# Lock files expected for each manifest found (K22-REPO-09).
$script:LockRules = @(
    @{ Manifest = '(^|/)[^/]+\.(cs|fs|vb)proj$|(^|/)Directory\.Packages\.props$'; Locks = 'packages\.lock\.json$'; Name = 'NuGet (packages.lock.json)' }
    @{ Manifest = '(^|/)package\.json$'; Locks = '(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?)$'; Name = 'npm' }
    @{ Manifest = '(^|/)pyproject\.toml$'; Locks = '(uv\.lock|poetry\.lock|pdm\.lock|pylock\.[^/]*toml)$'; Name = 'Python' }
    @{ Manifest = '(^|/)Cargo\.toml$'; Locks = 'Cargo\.lock$'; Name = 'Cargo' }
    @{ Manifest = '(^|/)go\.mod$'; Locks = 'go\.sum$'; Name = 'Go' }
    @{ Manifest = '(^|/)Package\.swift$'; Locks = 'Package\.resolved$'; Name = 'SwiftPM' }
    @{ Manifest = '(^|/)(build\.gradle(\.kts)?)$'; Locks = '(gradle\.lockfile|verification-metadata\.xml)$'; Name = 'Gradle' }
)

function Get-MissingLocks
{
    param([string[]] $Paths)
    foreach ($rule in $script:LockRules)
    {
        $manifests = @($Paths | Where-Object { $_ -match $rule.Manifest -and $_ -notmatch '(^|/)(samples?|examples?|templates?|tests?/fixtures)/' })
        if ($manifests.Count -eq 0) { continue }
        $locks = @($Paths | Where-Object { $_ -match $rule.Locks })
        if ($locks.Count -eq 0) { $rule.Name }
    }
}

# Any of these makes a repository buildable software rather than documentation (K22-REPO-02).
# True when workflow text calls a KofTwentyTwo/standards reusable release workflow
# pinned to a full commit SHA (K22-CI-30, K22-CI-11), or calls it by local path inside
# the standards repository itself.
function Test-StandardsReleaseCall
{
    param([string] $Text)
    return [bool] ($Text -match '(?m)^\s*(?:-\s+)?uses:\s*["'']?(KofTwentyTwo/standards/\.github/workflows/release-[A-Za-z0-9_.-]+\.ya?ml@[0-9a-f]{40}|\./\.github/workflows/release-[A-Za-z0-9_.-]+\.ya?ml)')
}

# Status contexts the protect-main ruleset must require for a repository with these
# files (K22-CI-01): the shared gates, plus the .NET gates when there is a solution
# or project file.
function Get-RequiredContexts
{
    param([string[]] $Paths)
    $contexts = [System.Collections.Generic.List[string]]::new()
    foreach ($context in $script:RequiredContexts) { $contexts.Add($context) }
    if (@($Paths | Where-Object { $_ -match '(^|/)[^/]+\.(slnx?|csproj)$' }).Count -gt 0)
    {
        $contexts.Add('ci / build-test')
        $contexts.Add('ci / format')
    }
    return , $contexts.ToArray()
}

$script:BuildManifestPattern = '(^|/)([^/]+\.(slnx?|csproj|fsproj|vbproj)|package\.json|pyproject\.toml|Cargo\.toml|go\.mod|pom\.xml|build\.gradle(\.kts)?|Package\.swift)$'

$script:BinaryPattern = '\.(exe|dll|so|dylib|a|lib|pdb|o|obj|class|jar|war|ear|pyc|nupkg|snupkg|msi|msix|appx|appxbundle|zip|7z|rar|tar|gz|tgz|bz2|xz|dmg|pkg|deb|rpm|apk|ipa|wasm)$'

# =================================================================================
# Self-test
# =================================================================================
function Invoke-SelfTest
{
    $failures = [System.Collections.Generic.List[string]]::new()
    function Assert([bool] $Condition, [string] $Name) { if (-not $Condition) { $failures.Add($Name) } }

    Assert ((Get-UsesPinState 'actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1') -eq 'PINNED') 'pin: full sha'
    Assert ((Get-UsesPinState 'actions/checkout@v7') -eq 'ref is not a full commit SHA') 'pin: tag'
    Assert ((Get-UsesPinState 'actions/checkout') -eq 'no ref') 'pin: no ref'
    Assert ((Get-UsesPinState './.github/workflows/pr.yml') -eq 'LOCAL') 'pin: local'
    Assert ((Get-UsesPinState ('docker://ghcr.io/x/y:1@sha256:' + ('a' * 64))) -eq 'PINNED') 'pin: digest'
    Assert ((Get-UsesPinState 'docker://ghcr.io/x/y:1') -eq 'image not pinned by digest') 'pin: image tag'
    Assert ((Get-UsesPinState 'Owner/repo/.github/workflows/x.yml@0123456789abcdef0123456789abcdef01234567') -eq 'PINNED') 'pin: reusable'

    $wf = @"
name: x
on: pull_request
permissions: {}
jobs:
  a:
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v7
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - run: echo "`${{ github.event.pull_request.title }}"
      - name: safe
        env:
          T: `${{ github.event.pull_request.title }}
        run: |
          echo "`$T"
          echo `${{ github.sha }}
      - run: |
          echo `${{ github.head_ref }}
"@
    Assert ((Get-TopLevelPermissions $wf) -eq '{}') 'permissions: inline'
    Assert ((Get-TopLevelPermissions "on: push`npermissions:`n  contents: read`njobs: {}") -eq 'contents: read') 'permissions: block'
    Assert ((Get-TopLevelPermissions "on: push`njobs: {}") -eq '') 'permissions: absent'
    Assert (@(Get-WorkflowUses $wf).Count -eq 2) 'uses: count'
    $inj = @(Find-TemplateInjection $wf)
    Assert ($inj.Count -eq 2) "injection: count ($($inj.Count))"
    Assert ($inj[0].Expression -eq 'github.event.pull_request.title') 'injection: title'
    Assert ($inj[1].Expression -eq 'github.head_ref') 'injection: head_ref'
    $persisted = @(Find-PersistedCheckout $wf)
    Assert ($persisted.Count -eq 1 -and $persisted[0] -eq 9) "checkout: persisted ($($persisted -join ','))"
    Assert (@(Find-PersistedCheckout "jobs:`n  check:`n    steps:`n      - uses: 'actions/checkout@v7'`n        with:`n          persist-credentials: true").Count -eq 1) 'checkout: quoted unsafe action'
    Assert (@(Find-TemplateInjection "jobs:`n  check:`n    steps:`n      - run: |2 # explicit indentation`n          echo `${{ github.head_ref }}").Count -eq 1) 'injection: block scalar indentation and comment'

    $register = @"
| ID | Status | Requirements | Scope | Expires |
| --- | --- | --- | --- | --- |
| [EX-0001](#ex-0001) | Open | K22-REPO-20 (approval count), OSPS-QA-07.01 | All repositories | 2027-10-01 |
| [EX-0002](#ex-0002) | Open | K22-CI-21 | KofTwentyTwo/gclo | 2026-12-31 |
| [EX-0003](#ex-0003) | Closed | K22-REPO-05 | All repositories | 2026-01-01 |
| [EX-0004](#ex-0004) | Open | K22-CODE-CS-03 | AppKit | 2027-01-01 |
"@
    $parsed = @(Read-ExceptionRegister $register)
    Assert ($parsed.Count -eq 4) 'register: rows'
    Assert ($parsed[3].Requirements -contains 'K22-CODE-CS-03') 'register: language IDs'
    Assert ((Find-Exception $parsed 'K22-REPO-20' 'KofTwentyTwo/AppKit' -Aspects @('approval count')).Id -eq 'EX-0001') 'exception: qualified aspect'
    Assert ($null -eq (Find-Exception $parsed 'K22-REPO-20' 'KofTwentyTwo/AppKit' -Aspects @('approval count', 'missing rule required_signatures'))) 'exception: other aspects not covered'
    Assert ($null -eq (Find-Exception $parsed 'K22-REPO-20' 'KofTwentyTwo/AppKit')) 'exception: qualified needs aspects'
    Assert ($parsed[0].Qualifiers['K22-REPO-20'] -eq 'approval count') 'register: qualifier parsed'
    Assert ((Find-Exception $parsed 'K22-CI-21' 'KofTwentyTwo/gclo').Id -eq 'EX-0002') 'exception: named repo'
    Assert ($null -eq (Find-Exception $parsed 'K22-CI-21' 'KofTwentyTwo/AppKit')) 'exception: other repo'
    Assert ($null -eq (Find-Exception $parsed 'K22-REPO-05' 'KofTwentyTwo/AppKit')) 'exception: closed'
    Assert ((Find-Exception $parsed 'K22-CODE-CS-03' 'KofTwentyTwo/AppKit').Id -eq 'EX-0004') 'exception: short name scope'
    Assert ($null -eq (Find-Exception $parsed 'K22-CODE-CS-03' 'KofTwentyTwo/AppKitExtras')) 'exception: no partial name match'
    $expired = @(Read-ExceptionRegister '| [EX-0099](#ex-0099) | Open | K22-REPO-12 | standards | 2026-11-10; review 2026-10-17 |')
    Assert ($null -ne (Find-Exception $expired 'K22-REPO-12' 'standards' -Today ([datetime] '2026-11-09'))) 'exception: valid before deadline'
    Assert ($null -eq (Find-Exception $expired 'K22-REPO-12' 'standards' -Today ([datetime] '2026-11-10'))) 'exception: expiry cannot silently authorize failure'
    $exactScope = @(Read-ExceptionRegister '| [EX-0099](#ex-0099) | Open | K22-REPO-12 | KofTwentyTwo/standards | 2099-01-01 |')
    Assert ($null -eq (Find-Exception $exactScope 'K22-REPO-12' 'AnotherOwner/standards')) 'exception: explicit owner scope cannot match another owner'
    Assert (@(Get-AssuranceCheck '{}' @() @{} '').Count -eq 2) 'assurance: missing schema returns both failures'
    Assert (@(Get-AssuranceCheck '{"schemaVersion":true}' @() @{} '' | Where-Object Status -eq 'FAIL').Count -eq 2) 'assurance: boolean cannot masquerade as schema version 1'
    Assert (@(Get-AssuranceCheck '{"schemaVersion":1,"badge":{},"fuzzing":{}}' @() @{} '' | Where-Object Status -eq 'FAIL').Count -eq 2) 'assurance: incomplete entries fail without crashing'
    $assurance = '{"schemaVersion":1,"badge":{"applicability":"required","reason":"public Product","projectUrl":"https://www.bestpractices.dev/projects/123","evidence":"docs/security/best-practices.md"},"fuzzing":{"applicability":"required","reason":"parser","targets":["tools/parser.ps1"],"command":"./tools/fuzz.ps1","workflow":".github/workflows/ci.yml","evidence":"docs/security/fuzzing.md"}}'
    $assurancePaths = @('tools/parser.ps1', 'docs/security/best-practices.md', 'docs/security/fuzzing.md')
    $assuranceWorkflow = @{ '.github/workflows/ci.yml' = "jobs:`n  tests:`n    steps:`n      - run: ./tools/fuzz.ps1 -Iterations 10" }
    $assuranceReadme = '[![Best Practices](https://www.bestpractices.dev/projects/123/badge)](https://www.bestpractices.dev/projects/123)'
    $assuranceRows = @(Get-AssuranceCheck $assurance $assurancePaths $assuranceWorkflow $assuranceReadme)
    Assert (@($assuranceRows | Where-Object Status -ne 'REVIEW').Count -eq 0) 'assurance: evidence needs human verification, never fabricated certification'
    Assert (@(Get-AssuranceCheck $assurance $assurancePaths $assuranceWorkflow '' | Where-Object { $_.Id -eq 'K22-REPO-12' -and $_.Status -eq 'FAIL' }).Count -eq 1) 'assurance: missing badge fails'
    $assuranceWorkflow['.github/workflows/ci.yml'] = "jobs:`n  tests:`n    steps:`n      - run: |`n          # ./tools/fuzz.ps1"
    Assert (@(Get-AssuranceCheck $assurance $assurancePaths $assuranceWorkflow $assuranceReadme | Where-Object { $_.Id -eq 'K22-TEST-25' -and $_.Status -eq 'FAIL' }).Count -eq 1) 'assurance: comment does not execute a fuzz command'
    Assert (@(Get-AssuranceCheck ($assurance.Replace('tools/parser.ps1', '../parser.ps1')) $assurancePaths $assuranceWorkflow $assuranceReadme | Where-Object { $_.Id -eq 'K22-TEST-25' -and $_.Status -eq 'FAIL' }).Count -eq 1) 'assurance: traversal paths cannot satisfy targets'

    Assert (@(Get-MissingLocks @('src/a/a.csproj', 'README.md')) -contains 'NuGet (packages.lock.json)') 'locks: missing nuget'
    Assert (@(Get-MissingLocks @('src/a/a.csproj', 'src/a/packages.lock.json')).Count -eq 0) 'locks: nuget ok'
    Assert (@(Get-MissingLocks @('samples/x/package.json')).Count -eq 0) 'locks: samples ignored'
    Assert (@(Get-MissingLocks @('Cargo.toml', 'Cargo.lock', 'go.mod')) -contains 'Go') 'locks: go'

    $sha = '0123456789abcdef0123456789abcdef01234567'
    Assert (Test-StandardsReleaseCall "jobs:`n  release:`n    uses: KofTwentyTwo/standards/.github/workflows/release-nuget.yml@$sha # v1.0.0") 'release call: pinned'
    Assert (-not (Test-StandardsReleaseCall "    uses: KofTwentyTwo/standards/.github/workflows/release-nuget.yml@main")) 'release call: branch ref'
    Assert (-not (Test-StandardsReleaseCall "    uses: KofTwentyTwo/standards/.github/workflows/dotnet.yml@$sha")) 'release call: not a release workflow'
    Assert (-not (Test-StandardsReleaseCall "    uses: Someone/standards/.github/workflows/release-nuget.yml@$sha")) 'release call: other owner'
    Assert (Test-StandardsReleaseCall "    uses: ./.github/workflows/release-nuget.yml") 'release call: local in standards'
    Assert ((Get-RequiredContexts @('AppKit.slnx', 'README.md')) -contains 'ci / build-test') 'contexts: dotnet build-test'
    Assert ((Get-RequiredContexts @('src/a/a.csproj')) -contains 'ci / format') 'contexts: dotnet format'
    Assert (-not ((Get-RequiredContexts @('README.md')) -contains 'ci / build-test')) 'contexts: docs repo'
    Assert ((Get-RequiredContexts @('README.md')) -contains 'security / sca') 'contexts: shared'

    Assert ('src/App/App.csproj' -match $script:BuildManifestPattern) 'manifest: csproj'
    Assert ('AppKit.slnx' -match $script:BuildManifestPattern) 'manifest: slnx'
    Assert ('tools/x/package.json' -match $script:BuildManifestPattern) 'manifest: nested package.json'
    Assert (-not ('policies/sdlc.md' -match $script:BuildManifestPattern)) 'manifest: docs file'
    Assert ('bin/app.exe' -match $script:BinaryPattern) 'binary: exe'
    Assert (-not ('Assets/app.ico' -match $script:BinaryPattern)) 'binary: icon allowed'

    if ($failures.Count -gt 0)
    {
        $failures | ForEach-Object { Write-Host "FAIL  $_" -ForegroundColor Red }
        Write-Host "$($failures.Count) self-test assertion(s) failed." -ForegroundColor Red
        exit 1
    }
    Write-Host 'Self-test passed.' -ForegroundColor Green
    exit 0
}

if ($LoadHelpers) { return }
if ($SelfTest) { Invoke-SelfTest }

# =================================================================================
# Repository access: local clone or GitHub API
# =================================================================================
if (-not $Repository -and -not $LocalPath) { throw 'Give -Repository owner/name, -LocalPath, or both.' }
if (-not $Repository -and -not $StaticOnly) { throw '-Repository is required unless -StaticOnly is used.' }
if ($StaticOnly -and -not $LocalPath) { throw '-StaticOnly needs -LocalPath.' }

function Invoke-GhApi
{
    # Returns @{ Ok; Status; Data }. Never throws for HTTP errors.
    param([string] $Path, [switch] $Paginate)
    $ghArgs = @('api', '-H', 'Accept: application/vnd.github+json', '-H', 'X-GitHub-Api-Version: 2022-11-28')
    if ($Paginate) { $ghArgs += @('--paginate', '--slurp') }
    $ghArgs += $Path
    $output = & gh @ghArgs 2>&1
    $text = ($output | ForEach-Object { "$_" }) -join "`n"
    if ($LASTEXITCODE -eq 0)
    {
        $data = if ($text.Trim()) { try { $text | ConvertFrom-Json -Depth 50 } catch { $text } } else { $null }
        return @{ Ok = $true; Status = 200; Data = $data }
    }
    $status = if ($text -match 'HTTP (\d{3})') { [int] $Matches[1] } else { 0 }
    return @{ Ok = $false; Status = $status; Data = $text }
}

$script:Paths = @()
$script:LocalRoot = $null
if ($LocalPath)
{
    $script:LocalRoot = (Resolve-Path $LocalPath).Path
    Push-Location $script:LocalRoot
    try
    {
        $tracked = git ls-files 2>$null
        if ($LASTEXITCODE -eq 0 -and $tracked)
        {
            $script:Paths = @($tracked)
            $untracked = @(git ls-files --others --exclude-standard 2>$null)
            $script:Paths += $untracked
        }
        else
        {
            $script:Paths = @(Get-ChildItem -Recurse -File -Force |
                Where-Object { $_.FullName -notmatch '[\\/](\.git|bin|obj|node_modules)[\\/]' } |
                ForEach-Object { [IO.Path]::GetRelativePath($script:LocalRoot, $_.FullName).Replace('\', '/') })
        }
    }
    finally { Pop-Location }
}
else
{
    $tree = Invoke-GhApi "repos/$Repository/git/trees/HEAD?recursive=1"
    if (-not $tree.Ok) { throw "Cannot list $Repository contents (HTTP $($tree.Status))." }
    $script:Paths = @($tree.Data.tree | Where-Object type -eq 'blob' | ForEach-Object path)
}

function Get-FileText
{
    param([string] $Path)
    if ($script:LocalRoot)
    {
        $full = Join-Path $script:LocalRoot $Path
        if (Test-Path -LiteralPath $full -PathType Leaf) { return Get-Content -LiteralPath $full -Raw }
        return $null
    }
    $r = & gh api -H 'Accept: application/vnd.github.raw' "repos/$Repository/contents/$Path" 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    return ($r -join "`n")
}

function Find-FirstPath
{
    param([string[]] $Candidates)
    foreach ($c in $Candidates)
    {
        $hit = $script:Paths | Where-Object { $_ -ieq $c } | Select-Object -First 1
        if ($hit) { return $hit }
    }
    return $null
}

$repoName = if ($Repository) { $Repository } else { Split-Path -Leaf $script:LocalRoot }
if (-not $Repository)
{
    # Local static checks can identify exact exception scope without contacting
    # GitHub. A clone with no canonical GitHub origin keeps its directory name.
    $origin = & git -C $script:LocalRoot remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0 -and $origin -match '^(?:https://github\.com/|git@github\.com:|ssh://git@(?:github\.com(?::22)?|ssh\.github\.com:443)/)([^/]+/[^/]+?)(?:\.git)?$') { $repoName = $Matches[1] }
}

# =================================================================================
# Static checks: required files (K22-REPO-01 .. 11)
# =================================================================================
$license = $script:Paths | Where-Object { $_ -match '^(LICENSE|LICENCE|COPYING)(\.(md|txt))?$|^LICENSES?/' } | Select-Object -First 1
if ($license) { Add-Result 'K22-REPO-01' 'PASS' $license } else { Add-Result 'K22-REPO-01' 'FAIL' 'no LICENSE, COPYING, or LICENSES/ at the root' }

$readmePath = Find-FirstPath @('README.md', 'README')
if (-not $readmePath) { Add-Result 'K22-REPO-02' 'FAIL' 'no README.md' }
else
{
    $readme = Get-FileText $readmePath
    $missing = @()
    # Documentation-only repositories (no build manifest) replace the install, usage,
    # and build sections with a single "How to use" section.
    $docsOnly = -not ($script:Paths | Where-Object { $_ -match $script:BuildManifestPattern } | Select-Object -First 1)
    if ($docsOnly)
    {
        if ($readme -notmatch '(?im)^#{1,3} .*how to use') { $missing += '"How to use" section (documentation-only repository)' }
    }
    else
    {
        if ($readme -notmatch '(?im)^#{1,3} .*(install|download|getting started)') { $missing += 'install section' }
        if ($readme -notmatch '(?im)^#{1,3} .*(usage|using|use |user guide|quick ?start)') { $missing += 'usage section' }
        if ($readme -notmatch '(?im)^#{1,3} .*(build|from source|develop)') { $missing += 'build-from-source section' }
    }
    if ($readme -notmatch '(?i)\btier\b') { $missing += 'tier statement' }
    if ($readme -notmatch '(?i)KofTwentyTwo standards') { $missing += 'standards version statement' }
    if ($readme -notmatch 'SECURITY\.md') { $missing += 'link to SECURITY.md' }
    if ($readme -notmatch 'CONTRIBUTING\.md') { $missing += 'link to CONTRIBUTING.md' }
    if ($missing) { Add-Result 'K22-REPO-02' 'FAIL' ('README.md lacks: ' + ($missing -join ', ')) } else { Add-Result 'K22-REPO-02' 'PASS' 'README.md has every required section' }
}

$missingHygiene = @('.gitignore', '.gitattributes', '.editorconfig') | Where-Object { -not (Find-FirstPath @($_)) }
if ($missingHygiene) { Add-Result 'K22-REPO-03' 'FAIL' ('missing ' + ($missingHygiene -join ', ')) }
else
{
    $attributes = Get-FileText '.gitattributes'
    if ($attributes -match '(?m)^\*\s+.*eol=lf') { Add-Result 'K22-REPO-03' 'PASS' '.gitignore, .gitattributes (LF), .editorconfig present' }
    else { Add-Result 'K22-REPO-03' 'WARN' '.gitattributes does not normalize to LF (`* text=auto eol=lf`); allowed only if the language profile says so' }
}

# K22-REPO-04: gitleaks over history when installed locally; API secret alerts otherwise.
$secretDetails = @()
$secretStatus = 'UNKNOWN'
if ($script:LocalRoot -and (Get-Command gitleaks -ErrorAction SilentlyContinue))
{
    $null = & gitleaks git $script:LocalRoot --redact --no-banner --exit-code 3 --log-level error 2>&1
    switch ($LASTEXITCODE)
    {
        0 { $secretStatus = 'PASS'; $secretDetails += 'gitleaks: no findings in history' }
        3 { $secretStatus = 'FAIL'; $secretDetails += "gitleaks found secrets (run: gitleaks git $LocalPath --redact)" }
        default { $secretDetails += "gitleaks could not scan (exit $LASTEXITCODE)" }
    }
}
else { $secretDetails += 'gitleaks not run (no local clone or not installed)' }
if (-not $StaticOnly)
{
    $alerts = Invoke-GhApi "repos/$Repository/secret-scanning/alerts?state=open&per_page=100"
    if ($alerts.Ok)
    {
        $count = @($alerts.Data).Count
        if ($count -gt 0) { $secretStatus = 'FAIL'; $secretDetails += "$count open secret-scanning alert(s)" }
        elseif ($secretStatus -ne 'FAIL') { $secretStatus = 'PASS'; $secretDetails += 'no open secret-scanning alerts' }
    }
    else { $secretDetails += "secret-scanning alerts unreadable (HTTP $($alerts.Status))" }
}
Add-Result 'K22-REPO-04' $secretStatus ($secretDetails -join '; ')

$binaries = @($script:Paths | Where-Object { $_ -match $script:BinaryPattern })
if ($binaries) { Add-Result 'K22-REPO-05' 'FAIL' ("$($binaries.Count) generated/binary file(s): " + (($binaries | Select-Object -First 5) -join ', ')) }
else { Add-Result 'K22-REPO-05' 'PASS' 'no generated executables or archives tracked' }

$securityPath = Find-FirstPath @('SECURITY.md', '.github/SECURITY.md', 'docs/SECURITY.md')
if (-not $securityPath) { Add-Result 'K22-REPO-06' 'FAIL' 'no SECURITY.md' }
else
{
    $security = Get-FileText $securityPath
    $missing = @()
    if ($security -notmatch '(?i)security/advisories/new|private vulnerability report|report a vulnerability') { $missing += 'private reporting instructions' }
    if ($security -notmatch '(?i)\b\d+\s*(business\s+)?days?\b') { $missing += 'response timeframes' }
    if ($security -notmatch '(?im)^#{1,3} .*support') { $missing += 'supported versions section' }
    if ($security -notmatch '(?i)contact|maintainer|@[A-Za-z0-9-]+') { $missing += 'security contact' }
    if ($missing) { Add-Result 'K22-REPO-06' 'FAIL' ("$securityPath lacks: " + ($missing -join ', ')) } else { Add-Result 'K22-REPO-06' 'PASS' $securityPath }
}

$contributingPath = Find-FirstPath @('CONTRIBUTING.md', '.github/CONTRIBUTING.md', 'docs/CONTRIBUTING.md')
if (-not $contributingPath) { Add-Result 'K22-REPO-07' 'FAIL' 'no CONTRIBUTING.md' }
else
{
    $contributing = Get-FileText $contributingPath
    $missing = @()
    if ($contributing -notmatch '(?i)signed-off-by|developer certificate of origin|\bDCO\b') { $missing += 'DCO sign-off' }
    if ($contributing -notmatch '(?i)conventional commit') { $missing += 'commit convention' }
    if ($contributing -notmatch '(?i)\btest') { $missing += 'how to run tests' }
    if ($missing) { Add-Result 'K22-REPO-07' 'FAIL' ("$contributingPath lacks: " + ($missing -join ', ')) } else { Add-Result 'K22-REPO-07' 'PASS' $contributingPath }
}

$codeownersPath = Find-FirstPath @('CODEOWNERS', '.github/CODEOWNERS', 'docs/CODEOWNERS')
if (-not $codeownersPath) { Add-Result 'K22-REPO-08' 'FAIL' 'no CODEOWNERS' }
elseif ((Get-FileText $codeownersPath) -match '(?m)^\*\s+@') { Add-Result 'K22-REPO-08' 'PASS' "$codeownersPath has a default owner" }
else { Add-Result 'K22-REPO-08' 'FAIL' "$codeownersPath has no '* @owner' rule" }

$missingLocks = @(Get-MissingLocks $script:Paths)
$anyManifest = @($script:LockRules | Where-Object { $rule = $_; $script:Paths | Where-Object { $_ -match $rule.Manifest } }).Count -gt 0
if (-not $anyManifest) { Add-Result 'K22-REPO-09' 'N/A' 'no package manifests found' }
elseif ($missingLocks) { Add-Result 'K22-REPO-09' 'FAIL' ('manifest without lock file: ' + ($missingLocks -join ', ')) }
else { Add-Result 'K22-REPO-09' 'PASS' 'every manifest has a lock file' }

if ($StaticOnly) { Add-Result 'K22-REPO-10' 'UNKNOWN' 'needs the API (static mode)' }
else
{
    $dotGithub = Invoke-GhApi "repos/$(($Repository -split '/')[0])/.github"
    if ($dotGithub.Ok) { Add-Result 'K22-REPO-10' 'PASS' 'account-wide .github repository exists' }
    else { Add-Result 'K22-REPO-10' 'FAIL' "no $(($Repository -split '/')[0])/.github repository for shared community files" }
}

if ($readmePath -and (Get-FileText $readmePath) -match '(?i)scorecard') { Add-Result 'K22-REPO-11' 'PASS' 'README shows the Scorecard badge' }
else { Add-Result 'K22-REPO-11' 'FAIL' 'README has no OpenSSF Scorecard badge' }

# =================================================================================
# Static checks: workflows (K22-CI-*)
# =================================================================================
$workflowPaths = @($script:Paths | Where-Object { $_ -match '^\.github/workflows/[^/]+\.ya?ml$' })
$workflows = @{}
foreach ($p in $workflowPaths) { $workflows[$p] = Get-FileText $p }
$allWorkflowText = ($workflows.Values -join "`n")

# Assurance records fail closed when required evidence is absent. A positive static
# check is REVIEW: identity, applicability and actual CI execution need verification.
$assuranceReadme = if ($readmePath) { Get-FileText $readmePath } else { '' }
if ($assuranceReadme -match '(?im)\bTier(?:\*\*)?\s*[:|]\s*(?:\*\*)?\s*Internal\b') { $script:Levels['K22-REPO-12'] = 'SHOULD' }
foreach ($check in Get-AssuranceCheck (Get-FileText 'docs/security/assurance.json') $script:Paths $workflows $assuranceReadme)
{
    Add-Result $check.Id $check.Status $check.Detail $check.Aspects
}

function Test-Calls
{
    # True when any workflow calls the named standards reusable workflow (by remote
    # reference or, inside the standards repository, by local path).
    param([string] $Name)
    return $allWorkflowText -match "(KofTwentyTwo/standards/\.github/workflows/$Name\.yml@|uses:\s*\./\.github/workflows/$Name\.yml)"
}

if ($workflowPaths.Count -eq 0)
{
    foreach ($id in 'K22-CI-01', 'K22-CI-10', 'K22-CI-11', 'K22-CI-12', 'K22-CI-13', 'K22-CI-14', 'K22-CI-15', 'K22-CI-18', 'K22-CI-20', 'K22-CI-21', 'K22-CI-22', 'K22-CI-23', 'K22-CI-24')
    {
        Add-Result $id 'FAIL' 'no GitHub Actions workflows'
    }
}
else
{
    # K22-CI-10: top-level permissions, never write at the top.
    $bad = foreach ($p in $workflowPaths)
    {
        $perm = Get-TopLevelPermissions $workflows[$p]
        if (-not $perm) { "$p (no top-level permissions)" }
        elseif ($perm -match 'write') { "$p ($perm)" }
    }
    if ($bad) { Add-Result 'K22-CI-10' 'FAIL' ('top-level permissions missing or writable: ' + (($bad | Select-Object -First 6) -join '; ')) }
    else { Add-Result 'K22-CI-10' 'PASS' "$($workflowPaths.Count) workflow(s) start read-only" }

    # K22-CI-11: SHA / digest pinning.
    $unpinned = foreach ($p in $workflowPaths)
    {
        foreach ($u in Get-WorkflowUses $workflows[$p])
        {
            $state = Get-UsesPinState $u.Uses
            if ($state -notin 'PINNED', 'LOCAL') { "$(Split-Path -Leaf $p):$($u.Line) $($u.Uses) ($state)" }
        }
        foreach ($m in [regex]::Matches($workflows[$p], '(?m)^\s*(?:image|container):\s*([^\s#]+)'))
        {
            if ($m.Groups[1].Value -notmatch '@sha256:' -and $m.Groups[1].Value -notmatch '^\$\{\{') { "$(Split-Path -Leaf $p) image $($m.Groups[1].Value) (not pinned by digest)" }
        }
    }
    if ($unpinned) { Add-Result 'K22-CI-11' 'FAIL' ("$(@($unpinned).Count) unpinned: " + ((@($unpinned) | Select-Object -First 5) -join '; ')) }
    else { Add-Result 'K22-CI-11' 'PASS' 'every action pinned to a commit SHA, every image to a digest' }

    # K22-CI-12: untrusted input interpolated into run:.
    $injections = foreach ($p in $workflowPaths)
    {
        foreach ($f in Find-TemplateInjection $workflows[$p]) { "$(Split-Path -Leaf $p):$($f.Line) `${{ $($f.Expression) }}" }
    }
    if ($injections) { Add-Result 'K22-CI-12' 'FAIL' ('untrusted input in run: ' + ((@($injections) | Select-Object -First 5) -join '; ')) }
    else { Add-Result 'K22-CI-12' 'PASS' 'no untrusted expressions inside run: (zizmor in CI is authoritative)' }

    # K22-CI-13: dangerous triggers.
    $dangerous = @($workflowPaths | Where-Object { $workflows[$_] -match '(?m)^\s*(pull_request_target|workflow_run)\s*:' })
    if ($dangerous) { Add-Result 'K22-CI-13' 'WARN' ('uses pull_request_target/workflow_run; confirm no PR code runs with secrets: ' + ($dangerous -join ', ')) }
    else { Add-Result 'K22-CI-13' 'PASS' 'no pull_request_target or workflow_run triggers' }

    # K22-CI-14: persist-credentials.
    $persisted = foreach ($p in $workflowPaths) { foreach ($line in Find-PersistedCheckout $workflows[$p]) { "$(Split-Path -Leaf $p):$line" } }
    if ($persisted) { Add-Result 'K22-CI-14' 'FAIL' ("checkout without persist-credentials: false at " + ((@($persisted) | Select-Object -First 8) -join ', ')) }
    else { Add-Result 'K22-CI-14' 'PASS' 'every checkout drops its credentials' }

    # K22-CI-15: no caches in release workflows.
    $releaseFlows = @($workflowPaths | Where-Object { $workflows[$_] -match '(?ms)^\s*tags:\s*(\[[^\]]*v\*|\r?\n\s*-\s*["'']?v\*)' })
    $cached = @($releaseFlows | Where-Object { $workflows[$_] -match 'actions/cache@|(?m)^\s*cache:\s*(true|[''"]?(npm|pip|yarn|pnpm|gradle|maven|nuget)[''"]?)|(?m)^\s*enable-cache:\s*true' })
    if ($releaseFlows.Count -eq 0) { Add-Result 'K22-CI-15' 'N/A' 'no tag-triggered release workflow' }
    elseif ($cached) { Add-Result 'K22-CI-15' 'FAIL' ('release workflow restores a cache: ' + ($cached -join ', ')) }
    else { Add-Result 'K22-CI-15' 'PASS' 'release workflows use no caches' }

    # K22-CI-17 (static half): self-hosted labels.
    $selfHosted = @($workflowPaths | Where-Object { $workflows[$_] -match '(?m)runs-on:.*self-hosted' })

    # K22-CI-18: timeouts on jobs that run steps.
    $jobsWithoutTimeout = foreach ($p in $workflowPaths)
    {
        $text = $workflows[$p]
        $stepsJobs = ([regex]::Matches($text, '(?m)^\s{4}steps:')).Count
        $timeouts = ([regex]::Matches($text, '(?m)^\s{4}timeout-minutes:')).Count
        if ($stepsJobs -gt $timeouts) { "$(Split-Path -Leaf $p) ($($stepsJobs - $timeouts) job(s))" }
    }
    if ($jobsWithoutTimeout) { Add-Result 'K22-CI-18' 'FAIL' ('jobs without timeout-minutes: ' + ($jobsWithoutTimeout -join ', ')) }
    else { Add-Result 'K22-CI-18' 'PASS' 'every job has a timeout' }

    # K22-CI-20..24: the scanners are wired in.
    $usesSecurity = Test-Calls 'security'
    if ($usesSecurity -or $allWorkflowText -match 'gitleaks') { Add-Result 'K22-CI-20' 'PASS' $(if ($usesSecurity) { 'security.yml (secrets job)' } else { 'gitleaks step' }) }
    else { Add-Result 'K22-CI-20' 'FAIL' 'no gitleaks scan in CI (call KofTwentyTwo/standards security.yml)' }

    # SCA = Trivy for CVEs plus OSV-Scanner for malicious (MAL-) packages.
    $scaWired = $usesSecurity -or ($allWorkflowText -match 'trivy' -and $allWorkflowText -match 'osv-scanner')
    $scheduled = @($workflowPaths | Where-Object { $workflows[$_] -match '(?m)^\s*schedule:' -and ($workflows[$_] -match 'security\.yml|trivy') })
    if ($scaWired -and $scheduled) { Add-Result 'K22-CI-21' 'PASS' 'SCA (CVEs and malicious packages) runs on changes and on a schedule' }
    elseif ($scaWired) { Add-Result 'K22-CI-21' 'FAIL' 'SCA is wired in but has no weekly schedule' }
    elseif ($allWorkflowText -match 'trivy') { Add-Result 'K22-CI-21' 'FAIL' 'Trivy runs but nothing checks for malicious packages (OSV-Scanner); call KofTwentyTwo/standards security.yml' }
    else { Add-Result 'K22-CI-21' 'FAIL' 'no SCA in CI (call KofTwentyTwo/standards security.yml)' }

    if ((Test-Calls 'codeql') -or ($allWorkflowText -match 'github/codeql-action/analyze@' -and $allWorkflowText -match 'security-extended'))
    {
        Add-Result 'K22-CI-22' 'PASS' 'CodeQL security-extended'
    }
    elseif ($allWorkflowText -match 'github/codeql-action/analyze@') { Add-Result 'K22-CI-22' 'FAIL' 'CodeQL runs without the security-extended suite or a severity gate' }
    else { Add-Result 'K22-CI-22' 'FAIL' 'no CodeQL workflow' }

    if ($usesSecurity -or ($allWorkflowText -match 'zizmor' -and $allWorkflowText -match 'actionlint')) { Add-Result 'K22-CI-23' 'PASS' 'zizmor and actionlint run in CI' }
    else { Add-Result 'K22-CI-23' 'FAIL' 'workflows are not linted by zizmor and actionlint in CI' }

    if ($allWorkflowText -match 'ossf/scorecard-action@') { Add-Result 'K22-CI-24' 'PASS' 'Scorecard workflow present' }
    else { Add-Result 'K22-CI-24' 'FAIL' 'no OpenSSF Scorecard workflow' }

    # K22-CI-30: release only through the standards' reusable release workflow.
    if ($releaseFlows.Count -eq 0) { Add-Result 'K22-CI-30' 'N/A' 'no tag-triggered release workflow' }
    else
    {
        $direct = @($releaseFlows | Where-Object { -not (Test-StandardsReleaseCall $workflows[$_]) })
        if ($direct.Count -eq 0) { Add-Result 'K22-CI-30' 'PASS' 'releases through a SHA-pinned KofTwentyTwo/standards release-*.yml reusable workflow' }
        else { Add-Result 'K22-CI-30' 'FAIL' ('tag workflow does not call a SHA-pinned KofTwentyTwo/standards release-*.yml (no SLSA Build L3): ' + ($direct -join ', ')) }
    }
}

Add-Result 'K22-CI-02' 'REVIEW' 'tests run on every PR and push: confirm in the language workflow'
Add-Result 'K22-CI-03' 'REVIEW' 'CI commands match CONTRIBUTING.md'
Add-Result 'K22-CI-31' 'REVIEW' 'the release workflow re-runs every main gate'

# =================================================================================
# GitHub settings (API)
# =================================================================================
if ($StaticOnly)
{
    foreach ($id in 'K22-REPO-20', 'K22-REPO-21', 'K22-REPO-22', 'K22-REPO-30', 'K22-REPO-31', 'K22-REPO-32', 'K22-REPO-40', 'K22-REPO-41', 'K22-CI-01', 'K22-CI-16')
    {
        Add-Result $id 'UNKNOWN' 'needs the API (static mode)'
    }
    if ($workflowPaths.Count -gt 0 -and $selfHosted) { Add-Result 'K22-CI-17' 'FAIL' ('self-hosted runner label in ' + ($selfHosted -join ', ')) }
    else { Add-Result 'K22-CI-17' 'UNKNOWN' 'no self-hosted labels in workflows; runner registrations need the API' }
}
else
{
    $repo = Invoke-GhApi "repos/$Repository"
    if (-not $repo.Ok) { throw "Cannot read $Repository (HTTP $($repo.Status))." }
    $r = $repo.Data

    # Maintainers with admin or maintain access decide the approval count (K22-REPO-20).
    $collaborators = Invoke-GhApi "repos/$Repository/collaborators?affiliation=all&per_page=100"
    $maintainerCount = if ($collaborators.Ok) { @($collaborators.Data | Where-Object { $_.permissions.admin -or $_.permissions.maintain }).Count } else { 1 }
    $expectedApprovals = if ($maintainerCount -ge 2) { 1 } else { 0 }

    $rulesets = Invoke-GhApi "repos/$Repository/rulesets?includes_parents=true&per_page=100"
    $mainRuleset = $null; $tagRuleset = $null
    if ($rulesets.Ok)
    {
        foreach ($rs in @($rulesets.Data))
        {
            $detail = Invoke-GhApi "repos/$Repository/rulesets/$($rs.id)"
            if (-not $detail.Ok) { continue }
            if ($rs.name -eq 'protect-main') { $mainRuleset = $detail.Data }
            if ($rs.name -eq 'protect-release-tags') { $tagRuleset = $detail.Data }
        }
    }

    if (-not $rulesets.Ok) { Add-Result 'K22-REPO-20' 'UNKNOWN' "rulesets unreadable (HTTP $($rulesets.Status))"; Add-Result 'K22-CI-01' 'UNKNOWN' 'rulesets unreadable' }
    elseif (-not $mainRuleset) { Add-Result 'K22-REPO-20' 'FAIL' 'no ruleset named protect-main'; Add-Result 'K22-CI-01' 'FAIL' 'no protect-main ruleset requiring the standard checks' }
    else
    {
        $problems = [System.Collections.Generic.List[string]]::new()
        $aspects = [System.Collections.Generic.List[string]]::new()
        if ($r.default_branch -ne 'main') { $problems.Add("default branch is '$($r.default_branch)'") }
        if ($mainRuleset.enforcement -ne 'active') { $problems.Add("enforcement is $($mainRuleset.enforcement)") }
        $includes = @($mainRuleset.conditions.ref_name.include)
        if (-not ($includes -contains '~DEFAULT_BRANCH' -or $includes -contains 'refs/heads/main')) { $problems.Add('does not target main') }
        if (@($mainRuleset.bypass_actors).Count -gt 0) { $problems.Add("$(@($mainRuleset.bypass_actors).Count) bypass actor(s)") }
        $rules = @{}
        foreach ($rule in @($mainRuleset.rules)) { $rules[$rule.type] = $rule }
        foreach ($t in 'deletion', 'non_fast_forward', 'pull_request', 'required_status_checks', 'required_linear_history', 'required_signatures')
        {
            if (-not $rules.ContainsKey($t)) { $problems.Add("missing rule $t") }
        }
        if ($rules.ContainsKey('pull_request'))
        {
            $pr = $rules['pull_request'].parameters
            if ($pr.required_approving_review_count -ne $expectedApprovals) { $problems.Add("approvals = $($pr.required_approving_review_count), expected $expectedApprovals for $maintainerCount maintainer(s)"); $aspects.Add('approval count') }
            if (-not $pr.required_review_thread_resolution) { $problems.Add('review threads need not be resolved') }
            if ($expectedApprovals -ge 1 -and -not $pr.dismiss_stale_reviews_on_push) { $problems.Add('stale approvals are not dismissed') }
            if ($expectedApprovals -ge 1 -and -not $pr.require_last_push_approval) { $problems.Add('last pusher may approve') }
        }
        if ($rules.ContainsKey('required_status_checks') -and -not $rules['required_status_checks'].parameters.strict_required_status_checks_policy)
        {
            $problems.Add('branch need not be up to date before merging')
        }
        # Every problem other than the approval count is its own aspect.
        foreach ($i in 0..($problems.Count - 1)) { if ($problems.Count -gt 0 -and $problems[$i] -notmatch '^approvals = ') { $aspects.Add($problems[$i]) } }
        if ($problems.Count -gt 0) { Add-Result 'K22-REPO-20' 'FAIL' ('protect-main: ' + ($problems -join '; ')) -Aspects $aspects }
        else { Add-Result 'K22-REPO-20' 'PASS' "protect-main complete ($expectedApprovals approval(s) for $maintainerCount maintainer(s))" }

        # K22-CI-01: required contexts.
        $contexts = if ($rules.ContainsKey('required_status_checks')) { @($rules['required_status_checks'].parameters.required_status_checks | ForEach-Object context) } else { @() }
        $missingContexts = @((Get-RequiredContexts $script:Paths) | Where-Object { $contexts -notcontains $_ })
        foreach ($prefix in $script:RequiredContextPrefixes) { if (-not ($contexts | Where-Object { $_.StartsWith($prefix) })) { $missingContexts += "$prefix (...)" } }
        if ($missingContexts) { Add-Result 'K22-CI-01' 'FAIL' ('protect-main does not require: ' + ($missingContexts -join ', ') + $(if ($contexts) { " (requires: $($contexts -join ', '))" } else { '' })) }
        else { Add-Result 'K22-CI-01' 'PASS' "requires $($contexts.Count) checks including every standard context" }
    }

    if (-not $rulesets.Ok) { Add-Result 'K22-REPO-21' 'UNKNOWN' 'rulesets unreadable' }
    elseif (-not $tagRuleset) { Add-Result 'K22-REPO-21' 'FAIL' 'no ruleset named protect-release-tags' }
    else
    {
        $problems = [System.Collections.Generic.List[string]]::new()
        if ($tagRuleset.target -ne 'tag') { $problems.Add("targets $($tagRuleset.target)") }
        if ($tagRuleset.enforcement -ne 'active') { $problems.Add("enforcement is $($tagRuleset.enforcement)") }
        if (@($tagRuleset.conditions.ref_name.include) -notcontains 'refs/tags/v*') { $problems.Add('does not target refs/tags/v*') }
        $types = @($tagRuleset.rules | ForEach-Object type)
        foreach ($t in 'creation', 'deletion', 'update', 'non_fast_forward') { if ($types -notcontains $t) { $problems.Add("missing rule $t") } }
        # Exactly one bypass actor: the repository admin role (RepositoryRole id 5), so
        # only the maintainer can create release tags.
        $bypass = @($tagRuleset.bypass_actors)
        $adminBypass = @($bypass | Where-Object { $_.actor_type -eq 'RepositoryRole' -and $_.actor_id -eq 5 })
        if ($adminBypass.Count -ne 1) { $problems.Add('the repository admin role is not the bypass actor') }
        if ($bypass.Count -ne $adminBypass.Count) { $problems.Add("$($bypass.Count - $adminBypass.Count) bypass actor(s) other than the repository admin role") }
        if ($problems.Count -gt 0) { Add-Result 'K22-REPO-21' 'FAIL' ('protect-release-tags: ' + ($problems -join '; ')) }
        else { Add-Result 'K22-REPO-21' 'PASS' 'release tags immutable; only the maintainer creates them' }
    }

    $mergeProblems = @()
    if (-not $r.allow_squash_merge) { $mergeProblems += 'squash merge disabled' }
    if ($r.allow_merge_commit) { $mergeProblems += 'merge commits allowed' }
    if ($r.allow_rebase_merge) { $mergeProblems += 'rebase merge allowed' }
    if (-not $r.delete_branch_on_merge) { $mergeProblems += 'head branches not auto-deleted' }
    if ($r.allow_squash_merge -and $r.squash_merge_commit_title -ne 'PR_TITLE') { $mergeProblems += "squash title is $($r.squash_merge_commit_title)" }
    if ($r.allow_squash_merge -and $r.squash_merge_commit_message -ne 'PR_BODY') { $mergeProblems += "squash message is $($r.squash_merge_commit_message)" }
    if ($mergeProblems) { Add-Result 'K22-REPO-22' 'FAIL' ($mergeProblems -join '; ') } else { Add-Result 'K22-REPO-22' 'PASS' 'squash only, PR title/body, branches auto-deleted' }

    # K22-REPO-30: security features.
    $sec = [System.Collections.Generic.List[string]]::new(); $unknown = [System.Collections.Generic.List[string]]::new()
    $pvr = Invoke-GhApi "repos/$Repository/private-vulnerability-reporting"
    if ($pvr.Ok) { if (-not $pvr.Data.enabled) { $sec.Add('private vulnerability reporting off') } } else { $unknown.Add('private vulnerability reporting') }
    $sa = $r.PSObject.Properties['security_and_analysis']
    if ($sa -and $sa.Value)
    {
        foreach ($feature in 'secret_scanning', 'secret_scanning_push_protection', 'dependabot_security_updates')
        {
            $f = $sa.Value.PSObject.Properties[$feature]
            if (-not $f -or $f.Value.status -ne 'enabled') { $sec.Add("$feature off") }
        }
    }
    else { $unknown.Add('security_and_analysis (needs admin)') }
    $alertsOn = Invoke-GhApi "repos/$Repository/vulnerability-alerts"
    if ($alertsOn.Ok) { } elseif ($alertsOn.Status -eq 404) { $sec.Add('Dependabot alerts off') } else { $unknown.Add('Dependabot alerts') }
    $cs = Invoke-GhApi "repos/$Repository/code-scanning/analyses?per_page=1"
    if ($cs.Ok) { if (@($cs.Data).Count -eq 0) { $sec.Add('code scanning has no analyses') } }
    elseif ($cs.Status -eq 404) { $sec.Add('code scanning not set up') } else { $unknown.Add('code scanning') }
    $imm = Invoke-GhApi "repos/$Repository/immutable-releases"
    if ($imm.Ok) { if (-not $imm.Data.enabled) { $sec.Add('immutable releases off') } } elseif ($imm.Status -eq 404) { $sec.Add('immutable releases off') } else { $unknown.Add('immutable releases') }
    if ($sec.Count -gt 0) { Add-Result 'K22-REPO-30' 'FAIL' ($sec -join '; ') }
    elseif ($unknown.Count -gt 0) { Add-Result 'K22-REPO-30' 'UNKNOWN' ('could not read: ' + ($unknown -join ', ')) }
    else { Add-Result 'K22-REPO-30' 'PASS' 'PVR, secret scanning + push protection, Dependabot alerts + updates, code scanning, immutable releases' }

    # K22-REPO-31 / 32: Actions permissions.
    $wfPerm = Invoke-GhApi "repos/$Repository/actions/permissions/workflow"
    $forkPolicy = Invoke-GhApi "repos/$Repository/actions/permissions/fork-pr-contributor-approval"
    if (-not $wfPerm.Ok) { Add-Result 'K22-REPO-31' 'UNKNOWN' "Actions permissions unreadable (HTTP $($wfPerm.Status))" }
    else
    {
        $p = @()
        if ($wfPerm.Data.default_workflow_permissions -ne 'read') { $p += "default GITHUB_TOKEN is $($wfPerm.Data.default_workflow_permissions)" }
        if ($wfPerm.Data.can_approve_pull_request_reviews) { $p += 'workflows can create/approve pull requests' }
        if ($forkPolicy.Ok) { if ($forkPolicy.Data.approval_policy -notin 'first_time_contributors', 'all_external_contributors') { $p += "fork PR approval policy is $($forkPolicy.Data.approval_policy)" } }
        else { $p += "fork PR approval policy unreadable (HTTP $($forkPolicy.Status))" }
        if ($p) { Add-Result 'K22-REPO-31' 'FAIL' ($p -join '; ') } else { Add-Result 'K22-REPO-31' 'PASS' 'read-only token, no PR approvals by workflows, outside contributors need approval' }
    }
    $actionsPerm = Invoke-GhApi "repos/$Repository/actions/permissions"
    if (-not $actionsPerm.Ok) { Add-Result 'K22-REPO-32' 'UNKNOWN' "unreadable (HTTP $($actionsPerm.Status))" }
    elseif ($actionsPerm.Data.allowed_actions -eq 'selected') { Add-Result 'K22-REPO-32' 'PASS' 'allowed actions restricted' }
    else { Add-Result 'K22-REPO-32' 'FAIL' "allowed actions: $($actionsPerm.Data.allowed_actions)" }

    $hyg = @()
    if (-not $r.has_issues) { $hyg += 'issues disabled' }
    if ($r.has_wiki) { $hyg += 'wiki enabled' }
    if ($hyg) { Add-Result 'K22-REPO-40' 'FAIL' ($hyg -join '; ') } else { Add-Result 'K22-REPO-40' 'PASS' 'issues on, wiki off' }

    $meta = @()
    if (-not $r.description) { $meta += 'no description' }
    if (@($r.topics).Count -eq 0) { $meta += 'no topics' }
    if (-not $r.homepage) { $meta += 'no homepage' }
    if ($meta) { Add-Result 'K22-REPO-41' 'FAIL' ($meta -join '; ') } else { Add-Result 'K22-REPO-41' 'PASS' 'description, topics, homepage' }

    # K22-CI-16: secrets live only in protected environments.
    $repoSecrets = Invoke-GhApi "repos/$Repository/actions/secrets"
    $envs = Invoke-GhApi "repos/$Repository/environments"
    if (-not $repoSecrets.Ok) { Add-Result 'K22-CI-16' 'UNKNOWN' "secrets unreadable (HTTP $($repoSecrets.Status))" }
    else
    {
        $names = @($repoSecrets.Data.secrets | ForEach-Object name)
        $envNotes = @()
        if ($envs.Ok)
        {
            foreach ($e in @($envs.Data.environments))
            {
                $policy = $e.deployment_branch_policy
                if (-not $policy -or (-not $policy.custom_branch_policies -and -not $policy.protected_branches)) { $envNotes += "environment '$($e.name)' has no deployment branch/tag policy" }
            }
        }
        if ($names.Count -gt 0) { Add-Result 'K22-CI-16' 'FAIL' ("repository-level secret(s) $($names -join ', '); move them into a tag-restricted environment or replace with OIDC" + $(if ($envNotes) { '; ' + ($envNotes -join '; ') } else { '' })) }
        elseif ($envNotes) { Add-Result 'K22-CI-16' 'FAIL' ($envNotes -join '; ') }
        else { Add-Result 'K22-CI-16' 'PASS' 'no repository-level secrets' }
    }

    # K22-CI-17: no self-hosted runners.
    $runners = Invoke-GhApi "repos/$Repository/actions/runners"
    if ($workflowPaths.Count -gt 0 -and $selfHosted) { Add-Result 'K22-CI-17' 'FAIL' ('self-hosted runner label in ' + ($selfHosted -join ', ')) }
    elseif (-not $runners.Ok) { Add-Result 'K22-CI-17' 'UNKNOWN' "runners unreadable (HTTP $($runners.Status))" }
    elseif ($runners.Data.total_count -gt 0) { Add-Result 'K22-CI-17' 'FAIL' "$($runners.Data.total_count) self-hosted runner(s) registered" }
    else { Add-Result 'K22-CI-17' 'PASS' 'GitHub-hosted runners only' }
}

# K22-REPO-42: listed in the account inventory.
$maintainersFile = Join-Path $StandardsPath 'MAINTAINERS.md'
if (-not (Test-Path $maintainersFile)) { Add-Result 'K22-REPO-42' 'UNKNOWN' "no MAINTAINERS.md under $StandardsPath" }
else
{
    $short = ($repoName -split '/')[-1]
    if ((Get-Content $maintainersFile -Raw) -match "(?i)\b$([regex]::Escape($short))\b") { Add-Result 'K22-REPO-42' 'PASS' 'listed in MAINTAINERS.md' }
    else { Add-Result 'K22-REPO-42' 'FAIL' "$short is not listed in KofTwentyTwo/standards MAINTAINERS.md" }
}

# =================================================================================
# Exceptions, output, exit code
# =================================================================================
$registerFile = Join-Path $StandardsPath 'exceptions/register.md'
$register = if (Test-Path $registerFile) { @(Read-ExceptionRegister (Get-Content $registerFile -Raw)) } else { @() }
foreach ($res in $script:Results)
{
    if ($res.Status -notin 'FAIL', 'WARN') { continue }
    $ex = Find-Exception -Register $register -RequirementId $res.Id -RepositoryName $repoName -Aspects $res.Aspects
    if ($ex) { $res.Status = 'EXCEPTED'; $res.Detail = "$($ex.Id): $($res.Detail)" }
}

$ordered = $script:Results | Sort-Object @{ Expression = { [array]::IndexOf(@($script:Levels.Keys), $_.Id) } }
$mustFailures = @($ordered | Where-Object { $_.Status -eq 'FAIL' -and $_.Level -eq 'MUST' })

if ($Json)
{
    [pscustomobject]@{
        repository = $repoName
        checkedAt  = (Get-Date).ToUniversalTime().ToString('o')
        mode       = $(if ($StaticOnly) { 'static' } else { 'full' })
        summary    = ($ordered | Group-Object Status | ForEach-Object { @{ $_.Name = $_.Count } })
        results    = $ordered
    } | ConvertTo-Json -Depth 5
}
else
{
    $colors = @{ PASS = 'Green'; FAIL = 'Red'; WARN = 'Yellow'; EXCEPTED = 'Cyan'; UNKNOWN = 'Magenta'; 'N/A' = 'DarkGray'; REVIEW = 'DarkGray' }
    Write-Host "KofTwentyTwo conformance: $repoName ($(if ($StaticOnly) { 'static' } else { 'full' }))"
    Write-Host ''
    foreach ($row in $ordered)
    {
        Write-Host ('{0,-12} {1,-6} ' -f $row.Id, $row.Level) -NoNewline
        Write-Host ('{0,-8}' -f $row.Status) -ForegroundColor $colors[$row.Status] -NoNewline
        Write-Host " $($row.Detail)"
    }
    Write-Host ''
    Write-Host (($ordered | Group-Object Status | Sort-Object Name | ForEach-Object { "$($_.Name): $($_.Count)" }) -join '  ')
}

if ($mustFailures.Count -gt 0) { exit 1 }
exit 0
