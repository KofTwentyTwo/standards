# How these standards work

> **Status: draft, pre-v1.0.0.** The requirements are written but have not been
> released. Until the first release (`v1.0.0`):
>
> - the automated checks and conformance tooling are still being built, so no
>   requirement is yet *Enforced* or *Verified* (see [compliance](../compliance/README.md));
> - no KofTwentyTwo repository claims conformance; adoption is in progress, starting
>   with this repository, [AppKit](https://github.com/KofTwentyTwo/AppKit), and
>   [gclo](https://github.com/KofTwentyTwo/gclo);
> - commitments to people outside the project (vulnerability response and fix times in
>   the [security program](security-program.md#vulnerability-management)) are targets
>   that the maintainer works to, and become binding commitments at `v1.0.0`.

This repository is the single source of truth for how KofTwentyTwo builds, secures,
and ships software. It has three layers, each more specific than the last:

| Layer | Folder | Answers | Changes |
| --- | --- | --- | --- |
| **Policy** | [`policies/`](.) | *What* must be true, and why | Rarely; each change is a MAJOR or MINOR release |
| **Standard** | [`standards/`](../standards) | *How* a policy is met: the concrete rules and tools | When practice or tooling moves |
| **Reference architecture** | [`architecture/`](../architecture) | A worked design that already meets the standards | When a product type is added or evolves |

Shared configuration in [`configs/`](../configs), reusable workflows in
[`.github/workflows/`](../.github/workflows), and the conformance checker in
[`tools/`](../tools) turn the standards into enforcement, so a requirement is never
only words.

## Requirement language

The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** are used as
described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and
[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in
bold capitals.

- **MUST** requirements apply to every in-scope repository. Not meeting one requires a
  recorded [exception](exceptions.md).
- **SHOULD** requirements are the default. Departing from one needs a reason written
  where the departure is (a code comment, the repository README, or the PR), not an
  exception.
- **MAY** describes an allowed option.

## Requirement IDs

Every requirement has a stable ID so it can be cited from code, CI output, PRs, and the
compliance crosswalks:

```text
K22-<AREA>-<NN>
```

| Area | Document | Covers |
| --- | --- | --- |
| `SDLC` | [policies/sdlc.md](sdlc.md) | Lifecycle, branching, commits, review, change control |
| `SEC` | [policies/security-program.md](security-program.md) | The security program: access, secrets, vulnerabilities, incidents |
| `AI` | [policies/ai-assisted-development.md](ai-assisted-development.md) | AI coding agents and AI-generated changes |
| `REPO` | [standards/repository.md](../standards/repository.md) | Repository files, settings, rulesets |
| `CI` | [standards/ci-cd.md](../standards/ci-cd.md) | Pipeline security and required checks |
| `TEST` | [standards/testing.md](../standards/testing.md) | Test levels, coverage, test hygiene |
| `DEP` | [standards/dependencies.md](../standards/dependencies.md) | Selecting, pinning, and updating dependencies |
| `REL` | [standards/releases.md](../standards/releases.md) | Versioning, signing, provenance, SBOM, support |
| `CODE` | [standards/coding/](../standards/coding/README.md) | Cross-language coding rules |
| `CODE-<LANG>` | `standards/coding/<language>.md` | One profile per language, e.g. `K22-CODE-CS-03` |

Rules for IDs:

- IDs are never reused or renumbered. A retired requirement keeps its ID with the text
  *Retired in vX.Y.Z* and a pointer to its replacement.
- Each requirement is written as one bolded line that starts with its ID and level,
  followed by the rule, then a short **Why** and **Verified by** line:

  > **K22-SDLC-01 (MUST)** The default branch is protected: no direct pushes, no
  > deletion, no force-push.
  > *Why:* every change is reviewed and gated. *Verified by:* `tools/Test-RepoConformance.ps1`
  > (ruleset check). *Maps to:* OSPS-AC-03.01, OSPS-AC-03.02.

- **Verified by** names the automation that proves the requirement, or the evidence a
  person checks when no automation is possible. A requirement with neither is a bug in
  this repository.

## Scope

These standards apply to every repository owned by the
[KofTwentyTwo](https://github.com/KofTwentyTwo) GitHub account, with two tiers:

| Tier | Which repositories | What applies |
| --- | --- | --- |
| **Product** | Public repositories that publish releases (apps, libraries, tools) | Everything |
| **Internal** | Private repositories, experiments, proofs of concept, configuration repos | Every **MUST** in `SEC` and `AI`, plus `K22-REPO-01`–`05`; the rest is **SHOULD** |

A repository's tier is stated in its README. A repository moves to *Product* before its
first public release.

## Versioning of the standards

This repository is versioned with [Semantic Versioning](https://semver.org) and released
as `vMAJOR.MINOR.PATCH`:

- **MAJOR**: a new **MUST** that existing repositories do not already meet, or a removed
  allowance.
- **MINOR**: a new **SHOULD**, new guidance, a new language profile or reference
  architecture.
- **PATCH**: clarification and fixes that change no obligation.

Repositories declare the version they conform to (for example `Conforms to KofTwentyTwo
standards v1.2`) in their README, and the conformance checker reports drift against the
current version.

## Frameworks we align with

The standards are original to KofTwentyTwo and are written against these public
frameworks. The crosswalks in [`compliance/`](../compliance) map each control to the
requirement that meets it.

| Framework | Version | Target |
| --- | --- | --- |
| [OpenSSF OSPS Baseline](https://baseline.openssf.org/) | v2026.08.28 | Level 3 for Product repositories, with recorded exceptions |
| [NIST SSDF (SP 800-218)](https://csrc.nist.gov/Projects/ssdf) | v1.1 (v1.2 draft tracked) | All practices applicable to an open-source maintainer |
| [SLSA](https://slsa.dev/) | v1.2 | Build L3 for released artifacts; Source L2 |
| [OpenSSF Scorecard](https://scorecard.dev/) | v5 | Score ≥ 8.0 on Product repositories |
| [EU Cyber Resilience Act](https://eur-lex.europa.eu/eli/reg/2024/2847/oj) | Regulation (EU) 2024/2847 | Practices aligned with open-source steward expectations |
