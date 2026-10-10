#Requires -Version 7.4
<#
.SYNOPSIS
Runs bounded, reproducible property tests against the conformance parsers.
.DESCRIPTION
Constructs workflows with independently known security properties, varying quotes,
indentation, comments, line endings, block scalars, and attacker expressions. Inputs
are data only: no generated script is executed and no GitHub access is needed.
A failure prints the seed, iteration, property, and synthetic input for replay.
.PARAMETER Seed
Seed for a deterministic sequence of generated cases.
.PARAMETER Iterations
Number of generated cases; bounded for pull-request CI.
#>
[CmdletBinding()]
param(
   [int] $Seed = 22023,
   [ValidateRange(1, 100000)]
   [int] $Iterations = 1000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Test-RepoConformance.ps1') -LoadHelpers
$random = [System.Random]::new($Seed)
$assertions = 0
$caseNumber = 0

<#
.SYNOPSIS
Fail with replay data when an independently generated security property is violated.
#>
function Assert-Property
{
   param([bool] $Condition, [string] $Property, [string] $InputText)
   if(-not $Condition)
   {
      $replay = [ordered]@{ seed = $Seed; iteration = $caseNumber; property = $Property; input = $InputText }
      throw ($replay | ConvertTo-Json -Compress)
   }
   $script:assertions++
}

<#
.SYNOPSIS
Generate synthetic hexadecimal action refs using the injected deterministic PRNG.
#>
function Get-HexString
{
   param([int] $Length)
   $characters = for($position = 0; $position -lt $Length; $position++)
   {
      '0123456789abcdef'[$random.Next(16)]
   }
   return -join $characters
}

for($caseNumber = 1; $caseNumber -le $Iterations; $caseNumber++)
{
   $newline = @("`n", "`r`n")[$random.Next(2)]
   $indent = ' ' * $random.Next(2, 5)
   $quote = @('', "'", '"')[$random.Next(3)]
   $sha = Get-HexString 40
   $uses = 'actions/checkout@' + $sha
   $pinnedWorkflow = @(
      'name: generated'
      'on: pull_request'
      'permissions: {}'
      'jobs:'
      ($indent + 'check:')
      ($indent * 2 + 'runs-on: ubuntu-24.04')
      ($indent * 2 + 'steps:')
      ($indent * 3 + '- uses: ' + $quote + $uses + $quote + ' # pinned')
      ($indent * 3 + '  with:')
      ($indent * 3 + '    persist-credentials: false')
   ) -join $newline
   $parsedUses = @(Get-WorkflowUses $pinnedWorkflow)
   Assert-Property -Condition ($parsedUses.Count -eq 1) -Property 'one generated action is found' -InputText $pinnedWorkflow
   Assert-Property -Condition ((Get-UsesPinState $parsedUses[0].Uses) -eq 'PINNED') -Property 'quoted full SHA remains pinned' -InputText $pinnedWorkflow
   Assert-Property -Condition (@(Find-PersistedCheckout $pinnedWorkflow).Count -eq 0) -Property 'explicit credential disabling is found' -InputText $pinnedWorkflow
   $unsafeCheckout = $pinnedWorkflow.Replace('persist-credentials: false', 'persist-credentials: true')
   Assert-Property -Condition (@(Find-PersistedCheckout $unsafeCheckout).Count -eq 1) -Property 'quoted unsafe checkout is never missed' -InputText $unsafeCheckout

   $badRef = @('v7', 'main', (Get-HexString 39), (Get-HexString 41))[$random.Next(4)]
   Assert-Property -Condition ((Get-UsesPinState ('actions/checkout@' + $badRef)) -ne 'PINNED') -Property 'non-SHA refs never pass pinning' -InputText $badRef

   $expression = @('github.event.pull_request.title', 'github.head_ref', 'inputs.payload')[$random.Next(3)]
   $indicator = @('|', '|-', '|+', '>', '>-', '>+', '|2', '|2-', '>2+')[$random.Next(9)]
   $expressionText = '${{ ' + $expression + ' }}'
   $injectionWorkflow = @(
      'permissions: {}'
      'jobs:'
      ($indent + 'check:')
      ($indent * 2 + 'steps:')
      ($indent * 3 + '- run: ' + $indicator + ' # generated scalar')
      ($indent * 3 + '    echo "' + $expressionText + '"')
   ) -join $newline
   $findings = @(Find-TemplateInjection $injectionWorkflow -IncludeInputs)
   Assert-Property -Condition ($findings.Count -eq 1) -Property 'untrusted expression in a block scalar is found' -InputText $injectionWorkflow
   Assert-Property -Condition ($findings[0].Expression -eq $expression) -Property 'finding preserves the controlled expression' -InputText $injectionWorkflow
   $safeWorkflow = $injectionWorkflow.Replace($expressionText, '${{ github.sha }}')
   Assert-Property -Condition (@(Find-TemplateInjection $safeWorkflow -IncludeInputs).Count -eq 0) -Property 'trusted expression is not reported' -InputText $safeWorkflow
   $envWorkflow = @(
      'jobs:'
      ($indent + 'check:')
      ($indent * 2 + 'steps:')
      ($indent * 3 + '- env:')
      ($indent * 3 + '    TITLE: ' + $expressionText)
      ($indent * 3 + '  run: echo "$TITLE"')
   ) -join $newline
   Assert-Property -Condition (@(Find-TemplateInjection $envWorkflow -IncludeInputs).Count -eq 0) -Property 'expressions in env stay outside run bodies' -InputText $envWorkflow

   $shortName = 'generated-' + $random.Next(100000).ToString([Globalization.CultureInfo]::InvariantCulture)
   $requirement = 'K22-CI-' + $random.Next(10, 25).ToString('00', [Globalization.CultureInfo]::InvariantCulture)
   $exception = '| [EX-0099](#ex-0099) | Open | ' + $requirement + ' | KofTwentyTwo/' + $shortName + ' | 2099-01-01 |'
   $register = @(Read-ExceptionRegister $exception)
   Assert-Property -Condition ($register.Count -eq 1) -Property 'generated exception row is parsed' -InputText $exception
   Assert-Property -Condition ($null -ne (Find-Exception $register $requirement ('KofTwentyTwo/' + $shortName))) -Property 'exact exception scope matches' -InputText $exception
   Assert-Property -Condition ($null -eq (Find-Exception $register $requirement ('KofTwentyTwo/' + $shortName + '-other'))) -Property 'partial repository names cannot gain an exception' -InputText $exception
   Assert-Property -Condition ($null -eq (Find-Exception $register $requirement ('AnotherOwner/' + $shortName))) -Property 'explicit scope cannot authorize another owner' -InputText $exception
   $closed = @(Read-ExceptionRegister $exception.Replace('| Open |', '| Closed |'))
   Assert-Property -Condition ($null -eq (Find-Exception $closed $requirement ('KofTwentyTwo/' + $shortName))) -Property 'closed exceptions cannot authorize a failure' -InputText $exception
   $expired = @(Read-ExceptionRegister $exception.Replace('2099-01-01', '2026-11-10'))
   Assert-Property -Condition ($null -eq (Find-Exception $expired $requirement ('KofTwentyTwo/' + $shortName) -Today ([datetime] '2026-11-10'))) -Property 'expired exceptions cannot authorize a failure' -InputText $exception

   $noise = -join (1..$random.Next(1, 128) | ForEach-Object { [char] $random.Next(32, 127) })
   foreach($parser in 'Get-WorkflowUses', 'Get-TopLevelPermissions', 'Get-RunBlocks', 'Find-TemplateInjection', 'Find-PersistedCheckout', 'Read-ExceptionRegister')
   {
      & $parser $noise | Out-Null
   }
   Get-AssuranceCheck $noise @() @{} '' | Out-Null
   $assertions++
}

Write-Output "PASS: conformance fuzz seed=$Seed iterations=$Iterations assertions=$assertions"
