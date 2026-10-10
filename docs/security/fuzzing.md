# Conformance parser fuzzing

## Scope and properties

K22-TEST-25 applies to shipped tooling even though most repository content is prose.
`tools/Test-RepoConformance.Fuzz.ps1` generates synthetic workflow and exception input
for the pure helpers in `tools/Test-RepoConformance.ps1`. It varies quotes, indentation,
comments, LF/CRLF, scalar indicators, action references and attacker expressions.
Independent construction supplies the expected security decision: only full SHA
pins pass; credential persistence and untrusted expressions are detected; expressions
in environment fields remain outside script bodies; exceptions match their exact
scope and must be open and unexpired. Bounded malformed ASCII inputs also exercise
parser robustness. These properties test unsafe acceptance, not only crashes.

This is native generated-input fuzzing, not coverage-guided instrumentation or a
complete YAML validator. Zizmor remains the authoritative workflow security gate.
Scorecard currently detects selected integrations; it may continue reporting zero
for this PowerShell harness. Do not claim OSS-Fuzz or ClusterFuzzLite enrollment.

## Running and replaying

PowerShell 7.4 or later is the only dependency; no network or profile is used.

```powershell
pwsh -NoProfile -File tools/Test-RepoConformance.Fuzz.ps1 -Seed 22023 -Iterations 1000
pwsh -NoProfile -File tools/Test-RepoConformance.Fuzz.ps1 -Seed 99173 -Iterations 1000
# Weekly and pre-MINOR/MAJOR campaigns: run both seeds at 10000 iterations.
pwsh -NoProfile -File tools/Test-RepoConformance.Fuzz.ps1 -Seed 22023 -Iterations 10000
pwsh -NoProfile -File tools/Test-RepoConformance.Fuzz.ps1 -Seed 99173 -Iterations 10000
```

Failures print synthetic input, property, iteration and seed as JSON. Replay with
that seed and at least that iteration count against the same checkout and PowerShell
runtime. Minimize the input into a named `-SelfTest` regression, then fix the parser
and rerun both seeds. Report suspected vulnerabilities through [SECURITY.md](../../SECURITY.md).

Inputs are bounded to small workflow fragments and fewer than 128 random ASCII
characters; iterations are limited to 100000. Generated scripts are never executed.
The harness does not write files, launch tools, or request repository credentials.
The required `ci / conformance` job runs both seeds on PRs and `main`, and 10000
iterations per seed on weekly schedules and release-tag validation, within its
10-minute timeout. Future failing seeds must be retained alongside regression cases.

## Review record

- **Owner:** @KofTwentyTwo; **reviewed:** 2026-10-10; **next review:** 2027-01-08.
- Seed 22023 exposed quoted-checkout and explicit-indentation block-scalar gaps;
  both now have deterministic self-test regressions. This is not a coverage claim.
- Reassess targets when parser boundaries change; generated data alone does not
  establish completeness or substitute for ordinary package and checker tests.
