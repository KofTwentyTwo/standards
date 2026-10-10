# Parser fuzzing assessment

## Applicability

Record the reviewed complex untrusted-input boundaries and their owner. If none
exist, explain why shipped tooling, importers, configuration and protocol handling
do not introduce one. Set `fuzzing.applicability` in `assurance.json` to `required`
or `not-applicable` with the actual rationale. Unfilled templates do not conform.

## Targets and properties

List each target, synthetic input limits, security invariants and corpus or seeds.
Use the language's native coverage-guided fuzzer where practical. Generated-input
property tests are an alternative when instrumentation is unavailable; assertions
must detect unsafe acceptance as well as crashes.

## Run and replay

Provide exact local commands, prerequisites, bounded PR/main campaign budgets,
weekly and pre-MINOR/MAJOR budgets, and the required CI job. Reference the target
paths, command and workflow in `assurance.json`; ensure the command actually runs
there rather than merely appearing in a comment. Explain how to replay and minimize
failures into regression tests. Never execute generated attacker scripts.

## Review

Name the owner, review date and next review (within 90 days). Reassess input
boundaries when they change. Do not claim a Scorecard-supported integration unless
it is genuinely configured and running; a score alone is not a test result.
