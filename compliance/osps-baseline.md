# Crosswalk: OpenSSF OSPS Baseline v2026.08.28

Every control of the [Open Source Project Security Baseline](https://baseline.openssf.org/)
([checklist](https://baseline.openssf.org/versions/2026-08-28-checklist.md)) and the
KofTwentyTwo requirement that meets it. **Target: Level 3 for Product repositories.**

Status: **Met** (a requirement covers it and is enforced or evidenced) ·
**Excepted** (recorded in the [exception register](../exceptions/register.md)).

## Level 1

| Control | Summary | Met by | Status |
| --- | --- | --- | --- |
| OSPS-AC-01.01 | MFA for access to sensitive resources | K22-SEC-01 | Met |
| OSPS-AC-02.01 | New collaborators get least privilege by default | K22-SEC-02 | Met |
| OSPS-AC-03.01 | Direct commits to the primary branch are prevented | K22-REPO-20, K22-SDLC-12 | Met |
| OSPS-AC-03.02 | Primary branch deletion is prevented | K22-REPO-20 | Met |
| OSPS-BR-01.01 | Untrusted metadata is sanitized in CI/CD | K22-CI-12 | Met |
| OSPS-BR-01.03 | Untrusted code cannot reach privileged CI credentials | K22-CI-13 | Met |
| OSPS-BR-03.01 | Official project channels use encrypted transport | K22-REL-10 | Met |
| OSPS-BR-03.02 | Distribution channels are authenticated against MITM | K22-REL-10, K22-DEP-10 | Met |
| OSPS-BR-07.01 | Unencrypted secrets are kept out of version control | K22-REPO-04, K22-REPO-30, K22-CI-20, K22-SEC-10 | Met |
| OSPS-DO-01.01 | User guides for basic functionality | K22-REPO-02 | Met |
| OSPS-DO-02.01 | Guide for reporting defects | K22-REPO-40, K22-REPO-10 (bug report form) | Met |
| OSPS-GV-02.01 | Public discussion mechanism | K22-REPO-40, K22-SDLC-01 | Met |
| OSPS-GV-03.01 | Contribution process documented | K22-REPO-07 | Met |
| OSPS-LE-02.01 | Source license is OSI/FSF approved | K22-REPO-01 | Met |
| OSPS-LE-02.02 | Released-asset license is OSI/FSF approved | K22-REPO-01 | Met |
| OSPS-LE-03.01 | License kept in the repository | K22-REPO-01 | Met |
| OSPS-LE-03.02 | License shipped with released assets | K22-REPO-01 | Met |
| OSPS-QA-01.01 | Source repository publicly readable at a static URL | [Scope](../policies/README.md#scope): Product repositories are public | Met |
| OSPS-QA-01.02 | Public record of all changes, authors, and times | K22-SDLC-14, K22-SDLC-16 | Met |
| OSPS-QA-02.01 | Dependency list for direct dependencies | K22-REPO-09, K22-DEP-11 | Met |
| OSPS-QA-04.01 | List of the project's codebases | K22-REPO-42 ([MAINTAINERS.md](../MAINTAINERS.md#repositories)) | Met |
| OSPS-QA-05.01 | No generated executables in version control | K22-REPO-05 | Met |
| OSPS-QA-05.02 | No unreviewable binaries in version control | K22-REPO-05 | Met |
| OSPS-VM-02.01 | Security contacts documented | K22-REPO-06, K22-SEC-40 | Met |

## Level 2

| Control | Summary | Met by | Status |
| --- | --- | --- | --- |
| OSPS-AC-04.01 | CI tasks default to the lowest permissions | K22-REPO-31, K22-CI-10 | Met |
| OSPS-BR-02.01 | Each release has a unique version | K22-REL-01, K22-REPO-21 | Met |
| OSPS-BR-04.01 | Releases carry a log of functional and security changes | K22-REL-02, K22-SEC-43 | Met |
| OSPS-BR-05.01 | Standard tooling ingests dependencies | K22-DEP-10 | Met |
| OSPS-BR-06.01 | Releases are signed or in a signed manifest of hashes | K22-REL-04 | Met |
| OSPS-DO-06.01 | How dependencies are selected, obtained, tracked | [Dependency standard](../standards/dependencies.md) | Met |
| OSPS-DO-07.01 | Build instructions | K22-REPO-02 | Met |
| OSPS-GV-01.01 | Members with access to sensitive resources listed | [MAINTAINERS.md](../MAINTAINERS.md), K22-SEC-02 | Met |
| OSPS-GV-01.02 | Roles and responsibilities described | [GOVERNANCE.md](../GOVERNANCE.md), [SDLC roles](../policies/sdlc.md#roles) | Met |
| OSPS-GV-03.02 | Contributor guide with acceptance requirements | K22-REPO-07 | Met |
| OSPS-LE-01.01 | Contributors assert legal authorization on every commit | K22-SDLC-13 (DCO) | Met |
| OSPS-QA-03.01 | Status checks pass (or are bypassed visibly) before merge | K22-REPO-20, K22-CI-01 | Met |
| OSPS-QA-06.01 | CI runs an automated test suite before acceptance | K22-CI-02, K22-TEST-01 | Met |
| OSPS-SA-01.01 | Design documentation of actions and actors | K22-SDLC-03 (threat model sections 2–3), reference architectures | Met |
| OSPS-SA-02.01 | External software interfaces described | K22-SDLC-03 (threat model section 4) | Met |
| OSPS-SA-03.01 | Security assessment performed | K22-SEC-30, K22-REL-12 | Met |
| OSPS-VM-01.01 | Coordinated vulnerability disclosure policy with timeframes | K22-SEC-40, K22-REPO-06 | Met |
| OSPS-VM-03.01 | Private vulnerability reporting to security contacts | K22-SEC-40, K22-REPO-30 | Met |
| OSPS-VM-04.01 | Discovered vulnerabilities published | K22-SEC-43 | Met |

## Level 3

| Control | Summary | Met by | Status |
| --- | --- | --- | --- |
| OSPS-AC-04.02 | CI jobs get minimum necessary privileges | K22-CI-10 | Met |
| OSPS-BR-01.04 | Trusted collaborator input is sanitized too | K22-CI-12 | Met |
| OSPS-BR-02.02 | Release assets tied to the release identifier | K22-REL-03 | Met |
| OSPS-BR-07.02 | Policy for managing secrets and credentials | K22-SEC-10, K22-SEC-11, K22-SEC-12, K22-CI-16 | Met |
| OSPS-DO-03.01 | Instructions to verify integrity and authenticity | K22-REL-21 | Met |
| OSPS-DO-03.02 | Instructions to verify the releasing identity | K22-REL-21 (`--signer-repo`) | Met |
| OSPS-DO-04.01 | Scope and duration of support per release | K22-REL-20, K22-REPO-06 | Met |
| OSPS-DO-05.01 | When versions stop receiving security updates | K22-REL-20, K22-SDLC-50 | Met |
| OSPS-GV-04.01 | Collaborators reviewed before escalated permissions | K22-SEC-02 | Met |
| OSPS-QA-02.02 | SBOM delivered with compiled release assets | K22-REL-06 | Met |
| OSPS-QA-04.02 | Subprojects as strict as the primary codebase | [Scope](../policies/README.md#scope): one standard for every Product repository | Met |
| OSPS-QA-06.02 | When and how tests run is documented | K22-CI-03, K22-REPO-07, K22-TEST-01 | Met |
| OSPS-QA-06.03 | Major changes add or update tests | K22-TEST-02, K22-SDLC-20 | Met |
| OSPS-QA-07.01 | Non-author human approval before merging | K22-SDLC-12 compensating controls | **Excepted** ([EX-0001](../exceptions/register.md#ex-0001)) |
| OSPS-SA-03.02 | Threat modeling and attack surface analysis | K22-SDLC-03, K22-SEC-30 | Met |
| OSPS-VM-04.02 | VEX for vulnerabilities that do not affect the project | K22-SEC-42 | Met |
| OSPS-VM-05.01 | Remediation threshold for SCA findings | K22-SEC-41 | Met |
| OSPS-VM-05.02 | SCA violations addressed before release | K22-SEC-42, K22-CI-31 | Met |
| OSPS-VM-05.03 | Changes evaluated against malicious and vulnerable dependencies, blocked on violation | K22-CI-01 (`pr / dependency-review`, `security / sca`), K22-DEP-30 | Met |
| OSPS-VM-06.01 | Remediation threshold for SAST findings | K22-SEC-41 | Met |
| OSPS-VM-06.02 | Changes evaluated for security weaknesses, blocked on violation | K22-CI-22, K22-CI-01 (`codeql / analyze`) | Met |

**Result:** 63 of 64 controls met; 1 excepted (single maintainer).
