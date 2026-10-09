# Security program

KofTwentyTwo's written information security program: how accounts, secrets, source
code, build systems, releases, and vulnerability reports are protected, and what happens
when something goes wrong.

This document states requirements, not operational detail. Inventories (which accounts
exist, where each secret is stored, recovery codes) are kept privately by the
maintainer and are never published.

**Owner and security contact:** the maintainer, see [MAINTAINERS.md](../MAINTAINERS.md).
**Review:** annually, after every security incident, and whenever a framework in
[policies/README.md](README.md#frameworks-we-align-with) publishes a new version.

## Scope

Everything that could change what a KofTwentyTwo user runs:

- the KofTwentyTwo GitHub account and every repository it owns;
- package registry accounts and namespaces (for example nuget.org, npm, PyPI,
  crates.io, Homebrew taps, winget manifests);
- signing identities (code signing, commit signing, notarization);
- cloud subscriptions used for signing or hosting;
- domains and email used for project identity and account recovery;
- development machines used to write and sign code.

## Accounts and access

**K22-SEC-01 (MUST)** Every account in scope uses multi-factor authentication, with a
phishing-resistant factor (passkey or hardware security key) wherever the service
supports one. SMS is never an enabled factor.
*Why:* credential phishing is the most common way projects are taken over.
*Verified by:* annual access review; GitHub account security settings. *Maps to:*
OSPS-AC-01.01.

**K22-SEC-02 (MUST)** Access follows least privilege. A new collaborator starts with
read or triage access; write, maintain, or admin access is granted only after review of
their contribution history, is recorded in [MAINTAINERS.md](../MAINTAINERS.md), and is
removed when no longer needed.
*Why:* every account with write access is an attack path. *Verified by:* annual access
review. *Maps to:* OSPS-AC-02.01, OSPS-GV-04.01.

**K22-SEC-03 (MUST)** Personal access tokens are fine-grained, scoped to the repositories
and permissions they need, and expire within 90 days. Classic tokens are not used
except where a tool supports nothing else, which is recorded as an exception.
*Why:* a leaked token is limited in reach and in time. *Verified by:* annual access
review of GitHub token settings.

**K22-SEC-04 (MUST)** At least once a year, and after any incident, the maintainer
reviews: repository collaborators, deploy keys, GitHub App and OAuth app grants, Actions
secrets and environments, registry API keys, and active tokens, and removes anything
not needed. The review is recorded as a closed issue in this repository.
*Why:* access accumulates silently. *Verified by:* the review issue.

## Secrets and credentials

**K22-SEC-10 (MUST)** Secrets are stored only in: 1Password (KofTwentyTwo's password
manager), the operating system's credential store (for an application's own user
credentials), or GitHub encrypted secrets bound to a protected environment.
They never appear in source, history, logs, CI output, issue or pull request text,
command-line arguments, or prompts to AI tools.
*Why:* each of those places is copied, cached, or published. *Verified by:* secret
scanning and gitleaks ([`K22-CI-20`](../standards/ci-cd.md)); log review in incident
handling. *Maps to:* OSPS-BR-07.01, OSPS-BR-07.02.

**K22-SEC-11 (MUST)** Where a service offers keyless authentication (OIDC federation
from GitHub Actions, trusted publishing), it is used instead of a stored secret.
*Why:* nothing to steal and nothing to rotate. *Verified by:*
[`K22-CI-16`](../standards/ci-cd.md#workflow-security).

**K22-SEC-12 (MUST)** Long-lived secrets are rotated at least yearly and immediately on
suspected exposure. A private inventory records each secret's purpose, location,
scope, and rotation date.
*Why:* rotation limits the life of an undetected leak. *Verified by:* the inventory
during the annual access review. *Maps to:* OSPS-BR-07.02.

**K22-SEC-13 (MUST)** A secret that is exposed (committed, logged, pasted, or reported)
is revoked first, then replaced, then the service's access logs are checked for use,
and the event is handled as an incident.
*Why:* removing a secret from a file does not un-leak it. *Verified by:* incident record.

**K22-SEC-14 (MUST)** Private keys never exist as files. SSH keys (authentication,
commit signing, deploy keys) are generated in 1Password and used through its SSH agent
([workstation standard](../standards/workstation.md#keys-and-secrets-live-in-1password));
release signing goes through a cloud HSM-backed service (Azure Trusted Signing for
Windows, Apple Developer ID for macOS). Private keys are never stored on disk or in CI
secrets.
*Why:* a stolen signing key lets an attacker ship malware as you, and a key file can be
copied silently. *Verified by:* `setup/Install-Workstation.ps1 -CheckOnly` (private keys
on disk, git signing through 1Password); signing configuration review.

## Development environment

**K22-SEC-20 (MUST)** Machines used to write, build, or sign KofTwentyTwo software have
full-disk encryption, automatic OS and browser updates, a screen lock, an enabled
firewall, and current malware protection.
*Why:* a compromised workstation compromises everything signed or pushed from it.
*Verified by:* annual self-attestation in the access review issue.

**K22-SEC-21 (MUST)** Developer tooling (IDE plugins, CLI tools, MCP servers, AI agents,
package-manager global tools) is installed from official sources, kept current, and
reviewed for the permissions it requests. Tools that can execute code or read
credentials are treated as dependencies.
*Why:* the development toolchain is a supply chain of its own. *Verified by:* annual
review.

## Secure development

The [SDLC policy](sdlc.md), the [AI policy](ai-assisted-development.md), and the
[standards](../standards) carry the secure-development controls: threat modeling
(`K22-SDLC-03`), code review (`K22-SDLC-12`), signed and certified commits
(`K22-SDLC-13`, `K22-SDLC-14`), pipeline hardening (`K22-CI-*`), dependency controls
(`K22-DEP-*`), and signed, attested releases (`K22-REL-*`).

**K22-SEC-30 (MUST)** Before each MINOR or MAJOR release of a Product, the maintainer
performs a security assessment: review the threat model against the changes since the
last release, confirm the scans are clean or excepted, and record the result in the
release checklist.
*Why:* a deliberate look at the most likely and most damaging problems, every release.
*Verified by:* the release checklist ([`K22-REL-12`](../standards/releases.md)). *Maps
to:* OSPS-SA-03.01, OSPS-SA-03.02.

## Vulnerability management

**K22-SEC-40 (MUST)** Vulnerabilities are reported privately through GitHub private
vulnerability reporting, as described in each repository's `SECURITY.md`. The
maintainer acknowledges a report within **7 days**, gives an initial assessment within
**14 days**, and coordinates disclosure with the reporter. The default disclosure
deadline is **90 days** from the report, earlier when a fix ships sooner, and earlier
still if the vulnerability is being exploited.
*Why:* reporters need a safe channel and a predictable timeline. *Verified by:*
`SECURITY.md` ([`K22-REPO-06`](../standards/repository.md)); advisory timelines.
*Maps to:* OSPS-VM-01.01, OSPS-VM-02.01, OSPS-VM-03.01.

**K22-SEC-41 (MUST)** Confirmed vulnerabilities, whether reported or found by scanners,
are fixed within these times from confirmation:

| Severity (CVSS v4 or the advisory's rating) | Fix released within |
| --- | --- |
| Critical | 7 days |
| High | 30 days |
| Medium | 90 days |
| Low | The next planned release |

The same thresholds apply to findings from software composition analysis and static
analysis. Findings that cannot be fixed in time (no upstream fix, for example) get a
recorded exception with mitigations.
*Why:* a promise users and reporters can hold the project to. *Verified by:* code
scanning and Dependabot alert ages. *Maps to:* OSPS-VM-05.01, OSPS-VM-06.01.

**K22-SEC-42 (MUST)** No release ships with a known, unexcepted HIGH or CRITICAL
vulnerability in code or dependencies it ships. A vulnerability that is present but not
exploitable in the product is documented in an [OpenVEX](https://openvex.dev/) statement
published with the release, with its justification; scanner suppressions reference that
statement and expire within 6 months.
*Why:* users get either a fix or an explanation, never silence. *Verified by:* release
gates ([`K22-CI-31`](../standards/ci-cd.md#release-pipelines)). *Maps to:*
OSPS-VM-04.02, OSPS-VM-05.02, OSPS-VM-05.03.

**K22-SEC-43 (MUST)** Every fixed vulnerability is published as a GitHub Security
Advisory with a CVE identifier (requested through GitHub's CNA), affected and fixed
versions, and credit to the reporter if they want it; the release notes of the fixing
release reference the advisory.
*Why:* users and their scanners can find out whether they are affected. *Verified by:*
the repository's Security Advisories page. *Maps to:* OSPS-VM-04.01, OSPS-BR-04.01.

**K22-SEC-44 (MUST)** A vulnerability that is being actively exploited, or an incident
that affects the security of released software, is announced to users through a
security advisory within **72 hours** of the maintainer becoming aware, even if the fix
is not yet available, with any available mitigation.
*Why:* users must be able to protect themselves before the fix lands. This timeline
also lines up with the EU Cyber Resilience Act's early-warning and notification
windows, should a KofTwentyTwo product ever fall in its scope. *Verified by:* advisory
timestamps.

## Incident response

An incident is any event that may have compromised the confidentiality, integrity, or
availability of KofTwentyTwo source, build systems, accounts, signing identities, or
released artifacts: a leaked secret, an unexpected commit or release, a compromised
dependency or action, a hijacked account.

**K22-SEC-50 (MUST)** Incidents are handled in this order, and recorded in a private
log as they happen:

1. **Contain**: revoke exposed credentials, disable affected workflows, remove
   compromised collaborators or apps, mark affected releases as compromised and unlist
   affected packages.
2. **Assess**: determine what was accessed or changed, when, and which releases and
   users are affected.
3. **Eradicate and recover**: remove the cause, rotate every credential the attacker
   could have reached, rebuild from a known-good commit, and release a new version.
   Compromised artifacts are never re-signed or re-published.
4. **Notify**: publish an advisory ([`K22-SEC-44`](#vulnerability-management)) and
   notify affected registries.
5. **Learn**: within 14 days, publish a post-incident review for incidents that
   affected users, and turn its findings into changes to these standards.

*Why:* a rehearsed order of operations prevents the most common mistake, cleaning up
before revoking. *Verified by:* incident records and published reviews.

**K22-SEC-51 (MUST)** If a release artifact or the release pipeline itself is
compromised, the affected release is marked as compromised in its notes and advisory,
every secret and signing identity reachable from the pipeline is rotated, and a new
version is released from a verified commit.
*Why:* users must be able to tell good builds from bad ones. *Verified by:* incident
record.

## Continuity

**K22-SEC-60 (MUST)** Every repository is backed up, with full history, to storage
outside GitHub at least weekly, and a restore is tested at least once a year.
*Why:* account loss or a platform outage must not lose the source. *Verified by:*
backup logs; the annual review issue.

**K22-SEC-61 (MUST)** Account recovery codes for every in-scope account are stored
offline, separate from the password manager.
*Why:* losing a device must not lose the project. *Verified by:* annual review.

**K22-SEC-62 (SHOULD)** A named successor and written continuity instructions (held
privately) let a trusted person transfer repositories and package namespaces if the
maintainer becomes unavailable.
*Why:* users depend on someone being able to ship a security fix. *Verified by:* annual
review.

## Data protection

**K22-SEC-70 (MUST)** KofTwentyTwo products collect no personal data unless the product
documents what it collects, why, where it is sent, and how long it is kept, and
collection is opt-in. Telemetry is off by default.
*Why:* privacy by default, and honesty when data must leave the user's machine.
*Verified by:* review of the product's README and threat model.

**K22-SEC-71 (MUST)** Products store user credentials only in the operating system's
credential store (Windows Credential Manager, macOS Keychain, the Secret Service on
Linux), never in plain files, and never log them.
*Why:* the OS store is protected by the user's login and hardware. *Verified by:* code
review; the product's threat model.
