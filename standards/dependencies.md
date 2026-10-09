# Dependency standard

How KofTwentyTwo selects, obtains, pins, updates, and tracks third-party software. This
document is the project's published description of dependency management.

## Selecting a dependency

**K22-DEP-01 (MUST)** A new runtime dependency is added only when the platform or
standard library cannot reasonably do the job, and the pull request that adds it states
why. Before adding it, check that it:

1. is actively maintained (a release or commit within the last 12 months, and issues
   being answered);
2. has a license on the allowlist below;
3. has no known HIGH or CRITICAL vulnerability in the version being added;
4. comes from an identifiable publisher, ideally with build provenance or trusted
   publishing on its registry;
5. scores reasonably on [OpenSSF Scorecard](https://scorecard.dev/) (5 or more is a
   good sign; below 3 needs a written reason).

*Why:* every dependency is code you ship and cannot fully review. *Verified by:*
`pr / dependency-review`; review. *Maps to:* OSPS-DO-06.01.

**K22-DEP-02 (MUST)** Dependencies that ship with a product are licensed under one of:
MIT, MIT-0, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, 0BSD, Zlib, Unlicense, CC0-1.0,
BSL-1.0, or MPL-2.0 (used unmodified). Anything else, including any GPL, LGPL, AGPL, or
SSPL variant, needs a recorded exception. Build-only tools may use any OSI-approved
license.
*Why:* a dependency's license becomes a condition on every user of the product.
*Verified by:* `pr / dependency-review` license allowlist.

## Obtaining and pinning

**K22-DEP-10 (MUST)** Dependencies are fetched only through the ecosystem's standard
package manager from its official registry over HTTPS: no vendored copies, no
`curl | sh` in builds, no downloads without a verified checksum.
*Why:* standard tooling verifies integrity and is what scanners understand.
*Verified by:* review; SCA scan. *Maps to:* OSPS-BR-05.01, OSPS-BR-03.02.

**K22-DEP-11 (MUST)** Direct dependency versions are exact or tightly bounded in the
manifest, the lock file is committed ([`K22-REPO-09`](repository.md#required-files)),
and CI restores in locked mode so a build can never resolve a version the lock file did
not record. Where the ecosystem supports central version management (for example
.NET `Directory.Packages.props`), it is used.
*Why:* the code that was reviewed and scanned is the code that ships.
*Verified by:* the language CI workflow (locked restore). *Maps to:* OSPS-QA-02.01.

## Updating

**K22-DEP-20 (MUST)** Dependabot (or Renovate) watches every ecosystem in the repository,
including GitHub Actions, at least weekly. Minor and patch updates are grouped; major
updates arrive individually. Non-security updates wait out a **cooldown of at least 3
days** after publication before a pull request is opened.
*Why:* staying current keeps upgrades small, and the cooldown lets the ecosystem catch
a malicious or broken release before it reaches you. *Verified by:* conformance
checker (`dependabot.yml` present and configured).

**K22-DEP-21 (MUST)** Security updates are opened immediately (no cooldown) and merged
within the remediation times of [`K22-SEC-41`](../policies/security-program.md#vulnerability-management).
*Why:* a known vulnerability is the cheapest one for an attacker. *Verified by:*
Dependabot alert ages.

## Malicious packages

**K22-DEP-30 (MUST)** Every pull request is checked against malware advisories as well
as vulnerability advisories, and a newly added package name is checked for
typosquatting and look-alikes of the package that was intended.
*Why:* malicious packages are published faster than they are caught; most attacks
rely on a near-miss name. *Verified by:* `security / sca` (OSV malicious-package
advisories); review
([`K22-AI-31`](../policies/ai-assisted-development.md#quality-of-ai-output) for
agent-added packages). *Maps to:* OSPS-VM-05.03.

## Tracking

**K22-DEP-40 (MUST)** The dependencies of each release are recorded in its SBOM
([`K22-REL-06`](releases.md)), and Dependabot alerts stay enabled so the inventory of
every supported release is monitored for new advisories.
*Why:* when the next widespread vulnerability is announced, the answer to "are we
affected?" is a lookup. *Verified by:* release assets; repository security settings.

**K22-DEP-41 (SHOULD)** Unused dependencies are removed (ecosystem tools such as
`cargo machete`, `depcheck`, or analyzer warnings for unused packages help find them).
*Why:* an unused dependency is all risk and no value. *Verified by:* review.
