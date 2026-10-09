# Security Policy

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Report it privately through GitHub's
[private vulnerability reporting](https://github.com/KofTwentyTwo/{{REPO}}/security/advisories/new)
(the repository's **Security** tab, then **Report a vulnerability**). That is the only
reporting channel.

Security contact: **James Maes** ([@KofTwentyTwo](https://github.com/KofTwentyTwo)),
maintainer.

Please include the affected version, how to reproduce it, and the impact you see.

## What to expect

KofTwentyTwo follows coordinated vulnerability disclosure. Timeframes are counted
from the day the report arrives and come from the
[KofTwentyTwo security program](https://github.com/KofTwentyTwo/standards/blob/main/policies/security-program.md):

| Step | Target |
| --- | --- |
| Acknowledge the report | 7 days |
| Assess it: confirm or reject, with a severity | 14 days |
| Release a fix for a CRITICAL vulnerability | 7 days |
| Release a fix for a HIGH vulnerability | 30 days |
| Release a fix for a MEDIUM vulnerability | 90 days |
| Release a fix for a LOW vulnerability | The next release |
| Publish the advisory (GitHub Security Advisory, CVE where applicable) | When the fix ships, or 90 days after the report, whichever comes first |

Reporters are credited in the advisory unless they ask not to be.

## Supported versions

| Version | Security fixes |
| --- | --- |
| {{LATEST_MAJOR_MINOR}}.x | Yes |
| Older | No; upgrade to the latest release |

{{State how long a release line is supported and when it stops receiving security
fixes, e.g. "Only the latest minor release receives fixes; a line ends when the next
minor version is released."}}

## Published vulnerabilities

Fixed vulnerabilities are published as
[GitHub Security Advisories](https://github.com/KofTwentyTwo/{{REPO}}/security/advisories).
