# Testing standard

How KofTwentyTwo code is tested, how much, and how the tests run. Language profiles in
[`coding/`](coding/README.md) name the frameworks and coverage tools for each stack.

## Test suites

**K22-TEST-01 (MUST)** Every repository that contains code has an automated test suite
that runs with one documented command locally and on every pull request and push to
`main` in CI.
*Why:* tests that are not run automatically stop being run. *Verified by:* the language
CI workflow; `CONTRIBUTING.md`. *Maps to:* OSPS-QA-06.01, OSPS-QA-06.02.

**K22-TEST-02 (MUST)** Every change in behavior adds or updates tests in the same pull
request. A bug fix adds a test that fails without the fix.
*Why:* the test suite is the specification; untested behavior is undefined behavior.
*Verified by:* coverage gate on changed code; review. *Maps to:* OSPS-QA-06.03.

**K22-TEST-03 (MUST)** Tests are organized by level, and each level has a clear job:

| Level | Tests | Runs | Required for |
| --- | --- | --- | --- |
| **Unit** | One unit of logic, fast, no network, no shared state | Every build | All code |
| **Integration** | Real collaborators: file system in temp folders, local databases or containers, real parsers | Every pull request | Code that touches I/O, persistence, external formats, or other processes |
| **End-to-end** | The shipped application, driven as a user would (UI automation, CLI invocation) | Every pull request where the runner supports it, otherwise before every release | Critical user flows of applications and CLIs |

*Why:* fast feedback from unit tests, confidence from the levels above them.
*Verified by:* review; CI configuration.

## Coverage

**K22-TEST-10 (MUST)** Line coverage is measured in CI and gated:

| Code | Minimum line coverage |
| --- | --- |
| Lines changed by the pull request (diff coverage) | 80% |
| Libraries published for others to consume, and UI-free core logic of applications | 100%, enforced per assembly or package |
| Whole repository | Reported, not gated |

Code is excluded from measurement only with the language's explicit exclusion marker
(for example `[ExcludeFromCodeCoverage(Justification = "...")]`) and a written reason,
and only for thin adapters over things a test cannot reach (native APIs, network
services, process lifecycle hooks). Generated code is excluded by configuration.
*Why:* coverage does not prove tests are good, but uncovered code is certainly
untested. A 100% bar on core logic is cheap to keep once reached and forces testable
design. *Verified by:* the coverage gate in the language workflow.

**K22-TEST-11 (SHOULD)** Libraries run mutation testing (for example Stryker.NET,
Stryker for JS, `cargo-mutants`, `mutmut`) at least before each MINOR release, and
surviving mutants in core logic become new tests or recorded decisions.
*Why:* mutation testing checks that tests can actually fail. *Verified by:* release
checklist.

## Test hygiene

**K22-TEST-20 (MUST)** Tests are deterministic and hermetic: no dependence on test
order, wall-clock time, time zones, locale, the network, or the developer's profile.
Time and randomness are injected; file system work happens in per-test temporary
directories; network-dependent tests are opt-in and labeled.
*Why:* a flaky suite gets ignored, and then it catches nothing. *Verified by:* review;
CI repeat runs.

**K22-TEST-21 (MUST)** A test that fails intermittently is fixed or quarantined with a
linked issue within one working day. A quarantined test does not count toward coverage
gates and is fixed or deleted within 30 days.
*Why:* flaky tests erode trust in every other test. *Verified by:* issue tracker.

**K22-TEST-22 (MUST)** Test data is synthetic. No real personal data, production
secrets, or customer material appears in tests or fixtures.
*Why:* test fixtures are published with the source. *Verified by:* secret scanning;
review.

**K22-TEST-23 (SHOULD)** Code that parses untrusted input (file formats, network
protocols, command lines, URLs) has negative tests for malformed input and, for
parsers of complex formats, a fuzz target run before each MINOR release.
*Why:* parsers are where memory-safety and injection bugs live. *Verified by:* review;
release checklist.

**K22-TEST-24 (MUST)** Tests never write to the user's real profile or settings;
applications expose a data-directory override (for example an environment variable)
that tests use.
*Why:* running tests must be safe on any machine. *Verified by:* review.

## Parser fuzzing

**K22-TEST-25 (MUST)** Repositories with complex parsers of untrusted input (including
workflow, configuration, protocol, archive, and document parsers) maintain fuzz
targets for those boundaries. Use coverage-guided fuzzing where supported; otherwise
use generated or mutated inputs with independent security properties. A crash-only
smoke test is insufficient when acceptance of unsafe input is the relevant failure.

Run bounded campaigns in a merge-gating CI job on every PR and push to `main`, and
longer campaigns at least weekly and before each MINOR or MAJOR release. Document
targets, input limits, invariants, a local replay command, seeds or corpus, CI job,
and failure handling in `docs/security/fuzzing.md`; declare the evidence, targets,
command and workflow in `docs/security/assurance.json`. Preserve minimized failures
as regression tests and fix or triage them before merging. Never execute generated
attacker scripts, use real secrets, or write to a user's profile.

Repositories without a complex untrusted-input parser document that decision and
its rationale in the same files; review applicability when input boundaries change
and at least every 90 days. Documentation-only status does not exempt shipped tooling.
*Why:* malformed inputs can cause unsafe acceptance as well as crashes; repeatable
fuzzing exercises combinations ordinary examples miss. *Verified by:* conformance
checker (scope record, target paths, command and CI reference); required CI execution
and review of properties, corpus and applicability. See the
[native PowerShell example](../docs/security/fuzzing.md). Scorecard recognition is
useful evidence, but is not a substitute for running appropriate targets.
