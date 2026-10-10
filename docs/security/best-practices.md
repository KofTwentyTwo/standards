# OpenSSF Best Practices evidence

## Enrollment and review

**Repository:** <https://github.com/KofTwentyTwo/standards>. **Owner:** @KofTwentyTwo.
**Prepared:** 2026-10-10. **Enrollment review:** 2026-10-17; **exception expiry:**
2026-11-10 ([EX-0007](../../exceptions/register.md#ex-0007)). Once enrolled, reassess
within 90 days and before each MINOR or MAJOR release.

The maintainer reported an anti-spam login restriction and deferred enrollment.
There is no registered project ID, submitted assessment, progress percentage, or
passing badge. The table below is prepared evidence for the current
[passing criteria](https://www.bestpractices.dev/en/criteria/0), not certification.
Use those criterion IDs in the provider's form; answers still require owner review.

## Criterion evidence matrix

IDs below omit the provider's `0.` level prefix. **Evidence** means source exists;
**Review** means operational evidence or human judgment is still needed;
**Proposed N/A** needs the provider's applicability rules and owner approval.

| Criteria | Prepared evidence / remaining decision | State |
| --- | --- | --- |
| `description_good`, `documentation_basics` | [README](../../README.md) describes standards, tooling and adoption | Evidence |
| `interact`, `discussion`, `report_process`, `report_tracker`, `report_archive` | Public [issues](https://github.com/KofTwentyTwo/standards/issues), templates and [CONTRIBUTING](../../CONTRIBUTING.md) | Evidence |
| `contribution`, `contribution_requirements` | CONTRIBUTING documents proposals, signed commits, DCO, review and gates | Evidence |
| `floss_license`, `floss_license_osi`, `license_location` | Root [MIT](../../LICENSE) for code, configs and templates; [CC BY 4.0](../../LICENSE-docs) for prose. Explain the separate documentation license | Evidence |
| `documentation_interface` | [Tool help and local commands](../../CONTRIBUTING.md#running-the-checks-locally), [release instructions](../releases.md); owner checks shipped tools' help completeness | Review |
| `sites_https`, `delivery_mitm` | GitHub repository and release delivery use HTTPS; [verification](../../standards/releases.md#verifying-a-release) checks provenance | Evidence |
| `english` | Repository documentation and contribution guidance are in English | Evidence |
| `maintained`, `report_responses`, `enhancement_responses` | Recent PRs/issues exist; a new project has limited response history. Assess actual responsiveness, not a policy promise | Review |
| `repo_public`, `repo_track`, `repo_interim`, `repo_distributed` | Public Git repository retains reviewed changes; signed history and protected main | Evidence |
| `version_unique`, `version_semver`, `version_tags`, `release_notes` | Immutable [v0.1.2](https://github.com/KofTwentyTwo/standards/releases/tag/v0.1.2), committed version and [changelog](../../CHANGELOG.md); failed unpublished tags are reserved | Evidence |
| `release_notes_vulns` | [Release standard](../../standards/releases.md) requires security fix notes; no published vulnerability fix history to attest to yet | Review |
| `vulnerability_report_process`, `vulnerability_report_private` | [SECURITY](../../SECURITY.md) links private GitHub reporting and supported versions | Evidence |
| `vulnerability_report_response` | SECURITY defines targets; maintainer confirms monitored contact and actual response capability | Review |
| `build`, `build_common_tools`, `build_floss_tools` | [Bundle builder](../../tools/Build-StandardsPackage.ps1) uses Git archives and PowerShell; prerequisites and release steps are documented | Evidence |
| `test`, `test_invocation`, `test_policy`, `tests_are_added`, `tests_documented_added` | CONTRIBUTING requires behavioral regression tests and documents checker, package and fuzz commands | Evidence |
| `test_continuous_integration` | [CI](../../.github/workflows/ci.yml) runs tests on PR/main, schedules and tag publication gates | Evidence |
| `test_most` | Parser properties, helper self-tests and package tests exist; no measured whole-tool coverage. Owner must assess most functionality, not infer it from case counts | Review |
| `warnings`, `warnings_fixed`, `warnings_strict` | Markdown/workflow gates reject findings. Broad PowerShell warning coverage is not established by Actions CodeQL; assess this gap separately | Review |
| `know_secure_design`, `know_common_errors` | [Threat model](threat-model.md), [security policy](../../policies/security-program.md) and parser regressions support discussion; a primary human developer must personally attest to the required knowledge | Review |
| `crypto_published`, `crypto_call`, `crypto_floss`, `crypto_keylength`, `crypto_working`, `crypto_weaknesses` | No custom product cryptography. GitHub TLS, SSH signing and attestations are delegated mechanisms; assess whether delegation meets each criterion or permits N/A | Review |
| `crypto_pfs` | No application server or product-controlled TLS configuration; document the hosted-service boundary if N/A is permitted | Proposed N/A |
| `crypto_password_storage` | No application passwords, password database or credential-storage implementation | Proposed N/A |
| `crypto_random` | The seeded fuzz PRNG generates only synthetic tests, never security keys/nonces. Cryptographic randomness is delegated to signing/hosting providers | Review |
| `delivery_unsigned` | Release assets have checksums, verified source, build provenance and GitHub immutable-release attestation; see [verification commands](../releases.md) | Evidence |
| `vulnerabilities_fixed_60_days`, `vulnerabilities_critical_fixed` | [Security program](../../policies/security-program.md#vulnerability-management) defines deadlines; maintainer must check current findings and known unpatched issues before answering | Review |
| `no_leaked_credentials` | Required [gitleaks and secret scans](../../.github/workflows/security.yml); scans support, but cannot prove, a universal absence claim | Review |
| `static_analysis`, `static_analysis_common_vulnerabilities`, `static_analysis_often` | [CodeQL Actions](../../.github/workflows/codeql.yml), zizmor and actionlint in required security gates; document PowerShell analysis coverage accurately | Evidence |
| `static_analysis_fixed` | Gates reject applicable findings; review unresolved alerts and [Scorecard dispositions](scorecard-dispositions.md) before claiming all important findings fixed | Review |
| `dynamic_analysis`, `dynamic_analysis_enable_assertions` | Executed [fuzz properties](fuzzing.md), deterministic helper and isolated package tests; assertions fail the job | Evidence |
| `dynamic_analysis_unsafe` | Shipped tooling is managed PowerShell, not unsafe native-language implementation; owner validates applicability | Proposed N/A |
| `dynamic_analysis_fixed` | Generated-input findings gained deterministic regressions; review all future campaign failures before assessment updates | Review |

## Completing enrollment

1. Retry normal GitHub login at <https://www.bestpractices.dev/en> after the provider
   restriction clears; register the exact repository above. Do not bypass anti-spam.
2. Review every proposed answer against the live criteria and actual evidence,
   including human knowledge, unresolved findings, and observed response history.
3. Put the actual project URL in [assurance.json](assurance.json) and add the
   provider's linked badge to README. Record the resulting assessment level honestly.
4. Close EX-0007 through a normal PR and set the next assessment review date.
   Work toward passing by resolving genuine gaps; registration is not passing.

Downstream repositories use the [assessment template](../../templates/repo/docs/security/best-practices.md)
and their own evidence and project ID; EX-0007 does not apply to them.
