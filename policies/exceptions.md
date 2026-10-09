# Exceptions

A **MUST** that cannot be met is never silently skipped: it is recorded as an
exception, with a reason, compensating controls, and an end date. All exceptions live
in one public register, [`exceptions/register.md`](../exceptions/register.md), so
anyone can see exactly where KofTwentyTwo falls short of its own standards and why.

## Process

1. Open a pull request against this repository that adds an entry to the register.
2. The entry states:
   - **ID**: `EX-NNNN`, never reused;
   - **Requirements**: the `K22-*` IDs (and framework controls) not met;
   - **Scope**: which repositories or artifacts;
   - **Reason**: why the requirement cannot be met now;
   - **Risk**: what could go wrong because of it;
   - **Compensating controls**: what reduces that risk in the meantime;
   - **Expires**: a date or a concrete condition (at most 12 months away); and
   - **Owner** and **review date**.
3. The pull request goes through the normal gates. The register is the approval record.
4. Code or configuration that relies on the exception cites its ID (for example a
   suppression comment `# K22 exception EX-0003`).

## Rules

- An exception expires on its date or condition. Before it expires it is either
  closed (the requirement is now met) or renewed by a pull request that explains why it
  is still needed.
- Expired exceptions are not deleted; their entry is marked **Closed** with the date and
  how it was resolved.
- An exception never covers secrets in source control (`K22-REPO-04`), bypassing the
  `main` ruleset (`K22-SDLC-12`), or skipping signing or attestation of a published
  release once signing is available (`K22-REL-04`, `K22-REL-05`).
- `tools/Test-RepoConformance.ps1` reports a failed requirement as `EXCEPTED` when an
  open, unexpired exception covers it for that repository.
