# Compliance crosswalks

KofTwentyTwo's standards are its own, but they are written against public frameworks so
that anyone can check how they measure up. Each crosswalk maps framework controls to
`K22-*` requirements.

| Framework | Crosswalk | Target | Result |
| --- | --- | --- | --- |
| OpenSSF OSPS Baseline v2026.08.28 | [osps-baseline.md](osps-baseline.md) | Level 3 | 63/64 met, 1 excepted |
| NIST SSDF v1.1 (SP 800-218) | [below](#nist-ssdf-v11) | All practices applicable to an open-source maintainer | Covered |
| SLSA v1.2 | [below](#slsa-v12) | Build L3, Source L2 | Build L3 by the shared release workflow |
| OpenSSF Scorecard v5 | [below](#openssf-scorecard) | ≥ 8.0 per Product repository | Measured weekly by the Scorecard workflow |

## NIST SSDF v1.1

The [Secure Software Development Framework](https://csrc.nist.gov/Projects/ssdf) groups
practices into four areas. Draft v1.2 (SP 800-218 Rev. 1, December 2025) is tracked;
this crosswalk is updated when it becomes final.

| SSDF practice | Met by |
| --- | --- |
| **PO.1** Define security requirements for development | These policies and standards; the [security program](../policies/security-program.md) |
| **PO.2** Implement roles and responsibilities | [GOVERNANCE.md](../GOVERNANCE.md), [SDLC roles](../policies/sdlc.md#roles) |
| **PO.3** Implement supporting toolchains | Reusable workflows, [`configs/`](../configs), pre-commit hooks, conformance checker |
| **PO.4** Define and use criteria for software security checks | K22-CI-01 required checks; K22-SEC-41 thresholds |
| **PO.5** Implement and maintain secure environments | K22-SEC-20, K22-SEC-21, K22-CI-10–17 |
| **PS.1** Protect all forms of code from unauthorized access and tampering | K22-REPO-20, K22-REPO-21, K22-SDLC-14, K22-SEC-01–04 |
| **PS.2** Provide a mechanism for verifying release integrity | K22-REL-04, K22-REL-05, K22-REL-21 |
| **PS.3** Archive and protect each release | K22-REL-07 (immutable releases), K22-SEC-60 (backups), K22-REL-06 (SBOM) |
| **PW.1** Design software to meet security requirements and mitigate risks | K22-SDLC-03 (threat model), reference architectures |
| **PW.2** Review the design | K22-SEC-30, K22-REL-12 |
| **PW.4** Reuse existing, well-secured software | K22-DEP-01, K22-DEP-02, AppKit |
| **PW.5** Create source code by adhering to secure coding practices | [Coding standards](../standards/coding/README.md), K22-AI-30 |
| **PW.6** Configure build processes to improve executable security | Language profiles (warnings as errors, analyzers, deterministic builds), K22-CI-30 |
| **PW.7** Review and/or analyze human-readable code | K22-SDLC-12, K22-CI-22 |
| **PW.8** Test executable code | [Testing standard](../standards/testing.md) |
| **PW.9** Configure software to have secure settings by default | K22-SEC-70, K22-SEC-71 |
| **RV.1** Identify and confirm vulnerabilities on an ongoing basis | K22-CI-21, K22-CI-22 (weekly scans), K22-DEP-40, K22-SEC-40 |
| **RV.2** Assess, prioritize, and remediate vulnerabilities | K22-SEC-41, K22-SEC-42 |
| **RV.3** Analyze vulnerabilities to identify their root causes | K22-SEC-50 (post-incident review) |

## SLSA v1.2

| Track | Level | How |
| --- | --- | --- |
| Build | **L3** | Releases are built only by a reusable workflow in `KofTwentyTwo/standards` on GitHub-hosted runners; GitHub artifact attestations sign the provenance, and `builder.id` identifies the reusable workflow (K22-CI-30, K22-REL-04) |
| Source | **L2** | Version-controlled history with protected branches and tags, verified signed commits, and no history rewrites (K22-REPO-20, K22-REPO-21, K22-SDLC-14, K22-SDLC-16). Source L3's continuous technical-control attestation is not yet produced |

## OpenSSF Scorecard

Scorecard checks and the requirement that drives each:

| Check | Driven by |
| --- | --- |
| Branch-Protection | K22-REPO-20 |
| CI-Tests | K22-CI-02 |
| Code-Review | K22-SDLC-12 (scores lower with one maintainer; see EX-0001) |
| Dangerous-Workflow | K22-CI-12, K22-CI-13 |
| Dependency-Update-Tool | K22-DEP-20 |
| License | K22-REPO-01 |
| Maintained | K22-SDLC-32 |
| Pinned-Dependencies | K22-CI-11, K22-DEP-11 |
| SAST | K22-CI-22 |
| Security-Policy | K22-REPO-06 |
| Signed-Releases | K22-REL-04 |
| Token-Permissions | K22-CI-10, K22-REPO-31 |
| Vulnerabilities | K22-SEC-41 |
| Binary-Artifacts | K22-REPO-05 |
| Packaging | K22-REL-11 |
| Fuzzing | K22-TEST-23 (where applicable) |
