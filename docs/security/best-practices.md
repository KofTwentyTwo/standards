# OpenSSF Best Practices evidence

## Enrollment and review

**Repository:** <https://github.com/KofTwentyTwo/standards>. **Owner:** @KofTwentyTwo.
**Assessment:** [project 15366](https://www.bestpractices.dev/en/projects/15366/passing).
**Level:** Passing. **Reviewed and earned:** 2026-10-10.
**Next review:** 2027-01-08, or before the next MINOR or MAJOR release, whichever
occurs first. Reassess at least every 90 days.

The public assessment identifies this repository and displays the passing badge.
The maintainer completed the self-assessment, including personal attestations.
This badge records voluntary maintainer self-certification.
The enrollment-only exception [EX-0007](../../exceptions/register.md#ex-0007) is
closed with the actual README badge and project URL recorded in
[assurance.json](assurance.json).

## Criterion evidence matrix

IDs below omit the provider's `0.` level prefix. **Evidence** means source exists;
**Review** marks ongoing operational evidence or human judgment to revalidate;
**Proposed N/A** preserves applicability reasoning for the next review. These are
local evidence notes; the linked public assessment holds the submitted answers.

| Criteria | Evidence and ongoing review | State |
| --- | --- | --- |
| `description_good`, `documentation_basics` | [README](../../README.md) describes standards, tooling and adoption | Evidence |
| `interact`, `discussion`, `report_process`, `report_tracker`, `report_archive` | Public [issues](https://github.com/KofTwentyTwo/standards/issues), templates and [CONTRIBUTING](../../CONTRIBUTING.md) | Evidence |
| `contribution`, `contribution_requirements` | CONTRIBUTING documents proposals, signed commits, DCO, review and gates | Evidence |
| `floss_license`, `floss_license_osi`, `license_location` | Root [MIT](../../LICENSE) for code, configs and templates; [CC BY 4.0](../../LICENSE-docs) for prose; attributed Apache-2.0 material in [NOTICE](../../NOTICE) | Evidence |
| `documentation_interface` | [Tool help and local commands](../../CONTRIBUTING.md#running-the-checks-locally), [release instructions](../releases.md); owner checks shipped tools' help completeness | Review |
| `sites_https`, `delivery_mitm` | GitHub repository and release delivery use HTTPS; [verification](../../standards/releases.md#verifying-a-release) checks provenance | Evidence |
| `english` | Repository documentation and contribution guidance are in English | Evidence |
| `maintained`, `report_responses`, `enhancement_responses` | Recent PRs/issues exist; a new project has limited response history. Assess actual responsiveness, not a policy promise | Review |
| `repo_public`, `repo_track`, `repo_interim`, `repo_distributed` | Public Git repository retains reviewed changes; signed history and protected main | Evidence |
| `version_unique`, `version_semver`, `version_tags`, `release_notes` | Immutable [v0.1.2](https://github.com/KofTwentyTwo/standards/releases/tag/v0.1.2), committed version and [changelog](../../CHANGELOG.md); failed unpublished tags are reserved | Evidence |
| `release_notes_vulns` | [Release standard](../../standards/releases.md) requires security fix notes; no published vulnerability fix history to attest to yet | Review |
| `vulnerability_report_process`, `vulnerability_report_private` | [SECURITY](../../SECURITY.md) links private GitHub reporting and supported versions | Evidence |
| `vulnerability_report_response` | Maintainer confirmed actual response compliance on 2026-10-10 in the public assessment; revalidate report history, not just SECURITY targets | Review |
| `build`, `build_common_tools`, `build_floss_tools` | [Bundle builder](../../tools/Build-StandardsPackage.ps1) uses Git archives and PowerShell; prerequisites and release steps are documented | Evidence |
| `test`, `test_invocation`, `test_policy`, `tests_are_added`, `tests_documented_added` | CONTRIBUTING requires behavioral regression tests and documents checker, package and fuzz commands | Evidence |
| `test_continuous_integration` | [CI](../../.github/workflows/ci.yml) runs tests on PR/main, schedules and tag publication gates | Evidence |
| `test_most` | Parser properties, helper self-tests and package tests exist; measured whole-tool coverage is not established | Suggested: Unmet |
| `warnings`, `warnings_fixed` | Markdown/workflow gates reject findings; revalidate applicable PowerShell warning handling | Review |
| `warnings_strict` | Maximal PowerShell warning/linter coverage across shipped tooling is not established by Actions CodeQL | Suggested: Unmet |
| `know_secure_design`, `know_common_errors` | Primary maintainer personally attested on 2026-10-10; supporting [threat model](threat-model.md), [security policy](../../policies/security-program.md) and parser regressions remain review evidence | Review |
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

## Maintaining the assessment

1. Review the public answers against current criteria and repository evidence by the
   next review date and before each MINOR or MAJOR release.
2. Reconfirm human knowledge, unresolved findings and actual response history with
   the maintainer; update answers when evidence or applicability changes.
3. Keep the provider's live badge, project URL and this review record synchronized.
   Downstream repositories need their own assessment and badge.
4. Improve the unmet suggested criteria `test_most` and `warnings_strict`; passing
   does not establish whole-tool coverage or maximal warning coverage. Track the
   shared release smoke-test gap in [issue #22](https://github.com/KofTwentyTwo/standards/issues/22).

Downstream repositories use the [assessment template](../../templates/repo/docs/security/best-practices.md)
and their own evidence and project ID; EX-0007 does not apply to them.
