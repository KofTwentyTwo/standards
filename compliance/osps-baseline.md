# Crosswalk: OpenSSF OSPS Baseline v2026.08.28

Every control of the [Open Source Project Security Baseline](https://baseline.openssf.org/)
([checklist](https://baseline.openssf.org/versions/2026-08-28-checklist.md)) and the
KofTwentyTwo requirement that meets it. **Target: Level 3 for Product repositories.**

> **Draft.** These standards have not had their first release. Every control below is
> covered by a written requirement, but the automated checks are still being built and
> no KofTwentyTwo repository has been verified against them yet. Statuses move forward
> only when there is evidence.

Status, in order of strength:

- **Defined**: a written `K22-*` requirement covers the control.
- **Enforced**: an automated check (a required CI check, a ruleset, or the conformance
  checker) fails when the requirement is not met.
- **Verified**: the conformance checker passes the requirement on every Product
  repository listed in [MAINTAINERS.md](../MAINTAINERS.md#repositories).
- **Excepted**: not met, with a recorded reason and compensating controls in the
  [exception register](../exceptions/register.md).

## Level 1

| Control | Summary | Met by | Status |
| --- | --- | --- | --- |
| OSPS-AC-01.01 | MFA for access to sensitive resources | K22-SEC-01 | Defined |
| OSPS-AC-02.01 | New collaborators get least privilege by default | K22-SEC-02 | Defined |
| OSPS-AC-03.01 | Direct commits to the primary branch are prevented | K22-REPO-20, K22-SDLC-12 | Defined |
| OSPS-AC-03.02 | Primary branch deletion is prevented | K22-REPO-20 | Defined |
| OSPS-BR-01.01 | Untrusted metadata is sanitized in CI/CD | K22-CI-12 | Defined |
| OSPS-BR-01.03 | Untrusted code cannot reach privileged CI credentials | K22-CI-13 | Defined |
| OSPS-BR-03.01 | Official project channels use encrypted transport | K22-REL-10 | Defined |
| OSPS-BR-03.02 | Distribution channels are authenticated against MITM | K22-REL-10, K22-DEP-10 | Defined |
| OSPS-BR-07.01 | Unencrypted secrets are kept out of version control | K22-REPO-04, K22-REPO-30, K22-CI-20, K22-SEC-10 | Defined |
| OSPS-DO-01.01 | User guides for basic functionality | K22-REPO-02 | Defined |
| OSPS-DO-02.01 | Guide for reporting defects | K22-REPO-40, K22-REPO-10 (bug report form) | Defined |
| OSPS-GV-02.01 | Public discussion mechanism | K22-REPO-40, K22-SDLC-01 | Defined |
| OSPS-GV-03.01 | Contribution process documented | K22-REPO-07 | Defined |
| OSPS-LE-02.01 | Source license is OSI/FSF approved | K22-REPO-01 | Defined |
| OSPS-LE-02.02 | Released-asset license is OSI/FSF approved | K22-REPO-01 | Defined |
| OSPS-LE-03.01 | License kept in the repository | K22-REPO-01 | Defined |
| OSPS-LE-03.02 | License shipped with released assets | K22-REPO-01 | Defined |
| OSPS-QA-01.01 | Source repository publicly readable at a static URL | [Scope](../policies/README.md#scope): Product repositories are public | Defined |
| OSPS-QA-01.02 | Public record of all changes, authors, and times | K22-SDLC-14, K22-SDLC-16 | Defined |
| OSPS-QA-02.01 | Dependency list for direct dependencies | K22-REPO-09, K22-DEP-11 | Defined |
| OSPS-QA-04.01 | List of the project's codebases | K22-REPO-42 ([MAINTAINERS.md](../MAINTAINERS.md#repositories)) | Defined |
| OSPS-QA-05.01 | No generated executables in version control | K22-REPO-05 | Defined |
| OSPS-QA-05.02 | No unreviewable binaries in version control | K22-REPO-05 | Defined |
| OSPS-VM-02.01 | Security contacts documented | K22-REPO-06, K22-SEC-40 | Defined |

## Level 2

| Control | Summary | Met by | Status |
| --- | --- | --- | --- |
| OSPS-AC-04.01 | CI tasks default to the lowest permissions | K22-REPO-31, K22-CI-10 | Defined |
| OSPS-BR-02.01 | Each release has a unique version | K22-REL-01, K22-REPO-21 | Defined |
| OSPS-BR-04.01 | Releases carry a log of functional and security changes | K22-REL-02, K22-SEC-43 | Defined |
| OSPS-BR-05.01 | Standard tooling ingests dependencies | K22-DEP-10 | Defined |
| OSPS-BR-06.01 | Releases are signed or in a signed manifest of hashes | K22-REL-04 | Defined |
| OSPS-DO-06.01 | How dependencies are selected, obtained, tracked | [Dependency standard](../standards/dependencies.md) | Defined |
| OSPS-DO-07.01 | Build instructions | K22-REPO-02 | Defined |
| OSPS-GV-01.01 | Members with access to sensitive resources listed | [MAINTAINERS.md](../MAINTAINERS.md), K22-SEC-02 | Defined |
| OSPS-GV-01.02 | Roles and responsibilities described | [GOVERNANCE.md](../GOVERNANCE.md), [SDLC roles](../policies/sdlc.md#roles) | Defined |
| OSPS-GV-03.02 | Contributor guide with acceptance requirements | K22-REPO-07 | Defined |
| OSPS-LE-01.01 | Contributors assert legal authorization on every commit | K22-SDLC-13 (DCO) | Defined |
| OSPS-QA-03.01 | Status checks pass (or are bypassed visibly) before merge | K22-REPO-20, K22-CI-01 | Defined |
| OSPS-QA-06.01 | CI runs an automated test suite before acceptance | K22-CI-02, K22-TEST-01 | Defined |
| OSPS-SA-01.01 | Design documentation of actions and actors | K22-SDLC-03 (threat model sections 2–3), reference architectures | Defined |
| OSPS-SA-02.01 | External software interfaces described | K22-SDLC-03 (threat model section 4) | Defined |
| OSPS-SA-03.01 | Security assessment performed | K22-SEC-30, K22-REL-12 | Defined |
| OSPS-VM-01.01 | Coordinated vulnerability disclosure policy with timeframes | K22-SEC-40, K22-REPO-06 | Defined |
| OSPS-VM-03.01 | Private vulnerability reporting to security contacts | K22-SEC-40, K22-REPO-30 | Defined |
| OSPS-VM-04.01 | Discovered vulnerabilities published | K22-SEC-43 | Defined |

## Level 3

| Control | Summary | Met by | Status |
| --- | --- | --- | --- |
| OSPS-AC-04.02 | CI jobs get minimum necessary privileges | K22-CI-10 | Defined |
| OSPS-BR-01.04 | Trusted collaborator input is sanitized too | K22-CI-12 | Defined |
| OSPS-BR-02.02 | Release assets tied to the release identifier | K22-REL-03 | Defined |
| OSPS-BR-07.02 | Policy for managing secrets and credentials | K22-SEC-10, K22-SEC-11, K22-SEC-12, K22-CI-16 | Defined |
| OSPS-DO-03.01 | Instructions to verify integrity and authenticity | K22-REL-21 | Defined |
| OSPS-DO-03.02 | Instructions to verify the releasing identity | K22-REL-21 (`--signer-repo`) | Defined |
| OSPS-DO-04.01 | Scope and duration of support per release | K22-REL-20, K22-REPO-06 | Defined |
| OSPS-DO-05.01 | When versions stop receiving security updates | K22-REL-20, K22-SDLC-50 | Defined |
| OSPS-GV-04.01 | Collaborators reviewed before escalated permissions | K22-SEC-02 | Defined |
| OSPS-QA-02.02 | SBOM delivered with compiled release assets | K22-REL-06 | Defined |
| OSPS-QA-04.02 | Subprojects as strict as the primary codebase | [Scope](../policies/README.md#scope): one standard for every Product repository | Defined |
| OSPS-QA-06.02 | When and how tests run is documented | K22-CI-03, K22-REPO-07, K22-TEST-01 | Defined |
| OSPS-QA-06.03 | Major changes add or update tests | K22-TEST-02, K22-SDLC-20 | Defined |
| OSPS-QA-07.01 | Non-author human approval before merging | K22-SDLC-12 compensating controls | **Excepted** ([EX-0001](../exceptions/register.md#ex-0001)) |
| OSPS-SA-03.02 | Threat modeling and attack surface analysis | K22-SDLC-03, K22-SEC-30 | Defined |
| OSPS-VM-04.02 | VEX for vulnerabilities that do not affect the project | K22-SEC-42 | Defined |
| OSPS-VM-05.01 | Remediation threshold for SCA findings | K22-SEC-41 | Defined |
| OSPS-VM-05.02 | SCA violations addressed before release | K22-SEC-42, K22-CI-31 | Defined |
| OSPS-VM-05.03 | Changes evaluated against malicious and vulnerable dependencies, blocked on violation | K22-CI-01 (`pr / dependency-review`, `security / sca`), K22-DEP-30 | Defined |
| OSPS-VM-06.01 | Remediation threshold for SAST findings | K22-SEC-41 | Defined |
| OSPS-VM-06.02 | Changes evaluated for security weaknesses, blocked on violation | K22-CI-22, K22-CI-01 (`codeql / analyze`) | Defined |

**Current result:** 63 of 64 controls Defined, 1 Excepted (single maintainer); 0 Enforced or Verified yet.
