# Security policy

## Reporting a vulnerability

**Do not open a public issue.** Report privately through GitHub:
[Security → Report a vulnerability](https://github.com/KofTwentyTwo/standards/security/advisories/new).

In this repository a vulnerability is anything that would weaken a repository that
adopts these standards: a reusable workflow that can be abused (injection, token
exposure, cache poisoning), a configuration that silently disables a check, or a
conformance check that passes when it should fail.

| Step | Timeframe |
| --- | --- |
| Acknowledgment | within 7 days |
| Initial assessment | within 14 days |
| Fix released | Critical 7 days, High 30 days, Medium 90 days, Low next release, from confirmation |
| Public disclosure | coordinated with the reporter; by default 90 days after the report, sooner once fixed |

Until this repository's first release (`v1.0.0`) these timeframes are targets the
maintainer works to; from `v1.0.0` they are commitments.

Fixed vulnerabilities are published as GitHub Security Advisories with a CVE. These
timeframes come from the [security program](policies/security-program.md#vulnerability-management)
that this repository defines for all KofTwentyTwo projects.

**Security contact:** the maintainer listed in [MAINTAINERS.md](MAINTAINERS.md).

## Supported versions

Only the latest release of this repository is supported. Repositories that call the
reusable workflows pin them by commit SHA; Dependabot proposes the update when a new
release is published, including security fixes.

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| Anything older | No: update the pinned SHA to the latest release |
