# Repository standard

What every KofTwentyTwo repository contains and how it is configured on GitHub. The
settings half of this standard is checked automatically by
[`tools/Test-RepoConformance.ps1`](../tools/Test-RepoConformance.ps1); the
[`templates/repo/`](../templates/repo) folder holds starting copies of every required
file.

Requirements `K22-REPO-01` to `05` apply to all tiers; the rest apply to Product
repositories and are **SHOULD** for Internal ones (see [scope](../policies/README.md#scope)).

## Required files

**K22-REPO-01 (MUST)** The repository has a `LICENSE` file at its root containing an
OSI-approved license. Code defaults to MIT; documentation-only repositories may use
CC BY 4.0. Released artifacts carry the same license file.
*Why:* nobody can legally use, fork, or contribute without it. *Verified by:*
conformance checker (file present, GitHub license detection). *Maps to:* OSPS-LE-02.01,
OSPS-LE-02.02, OSPS-LE-03.01, OSPS-LE-03.02.

**K22-REPO-02 (MUST)** `README.md` states what the project is, its tier, the standards
version it conforms to, how to install and use it, how to build it from source
(toolchain and dependencies included), and links to `SECURITY.md` and `CONTRIBUTING.md`.
*Why:* the README is the user guide and the build guide. *Verified by:* conformance
checker (file and required headings); review. *Maps to:* OSPS-DO-01.01, OSPS-DO-07.01.

**K22-REPO-03 (MUST)** `.gitignore`, `.gitattributes`, and `.editorconfig` are present.
`.gitattributes` normalizes text to LF (`* text=auto eol=lf`) unless the language
profile says otherwise; `.editorconfig` comes from the language profile in
[`configs/`](../configs).
*Why:* consistent bytes on every OS keep diffs and format gates honest. *Verified by:*
conformance checker.

**K22-REPO-04 (MUST)** No secrets, credentials, private keys, or personal data are ever
committed, and none exist in history. A secret that reaches a commit is treated as
compromised and rotated, even if the commit is rewritten.
*Why:* git history is permanent and public repositories are scraped within minutes.
*Verified by:* GitHub secret scanning with push protection, gitleaks in pre-commit and
CI ([`K22-CI-08`](ci-cd.md)). *Maps to:* OSPS-BR-07.01.

**K22-REPO-05 (MUST)** The repository contains no generated executables and no
unreviewable binaries: no compiled output, no packaged dependencies, no archives.
Binary *assets* that are part of the product (icons, images, fonts) are allowed when
their source or generator is in the repository or documented.
*Why:* a binary in source control cannot be reviewed and is a classic place to hide
malicious code. *Verified by:* conformance checker (extension and size scan); review.
*Maps to:* OSPS-QA-05.01, OSPS-QA-05.02.

**K22-REPO-06 (MUST)** `SECURITY.md` names the security contact, says how to report a
vulnerability privately (GitHub private vulnerability reporting), states the response
timeframes from the [security program](../policies/security-program.md#vulnerability-management),
and lists which versions receive security fixes and for how long.
*Why:* a reporter must know where to go and what to expect; a user must know whether
their version is still safe. *Verified by:* conformance checker (file and sections).
*Maps to:* OSPS-VM-01.01, OSPS-VM-02.01, OSPS-VM-03.01, OSPS-DO-04.01, OSPS-DO-05.01.

**K22-REPO-07 (MUST)** `CONTRIBUTING.md` explains how to propose a change, the branch
and commit conventions, the DCO sign-off, how to build and run the tests locally, which
CI checks gate a merge, and what makes a contribution acceptable (tests, docs, no new
warnings). A repository that does not accept contributions says so instead.
*Why:* contributors meet the bar on the first try instead of in review. *Verified by:*
conformance checker (file present). *Maps to:* OSPS-GV-03.01, OSPS-GV-03.02,
OSPS-QA-06.02.

**K22-REPO-08 (MUST)** `CODEOWNERS` assigns an owner to every path (`* @KofTwentyTwo`
at minimum).
*Why:* review routing and an explicit statement of accountability. *Verified by:*
conformance checker.

**K22-REPO-09 (MUST)** The direct dependencies are declared in the ecosystem's standard
manifest, and a lock file pins the full resolved graph (for example
`packages.lock.json`, `package-lock.json`, `uv.lock`, `Cargo.lock`, `go.sum`,
`Package.resolved`). See [dependencies](dependencies.md).
*Why:* reproducible builds and complete vulnerability scanning both need the resolved
graph. *Verified by:* conformance checker; the SCA scan reads the lock file. *Maps to:*
OSPS-QA-02.01.

**K22-REPO-10 (SHOULD)** Community files that are the same everywhere (code of conduct,
issue and PR templates, funding, support) are inherited from the account-wide
[`KofTwentyTwo/.github`](https://github.com/KofTwentyTwo/.github) repository rather than
copied, unless the repository needs its own.
*Why:* one place to update. *Verified by:* GitHub community profile.

**K22-REPO-11 (SHOULD)** The README carries the OpenSSF Scorecard badge and, for
released software, links to the latest release and the verification instructions in
[releases](releases.md#verifying-a-release).
*Why:* users can see the security posture before they install. *Verified by:* review.

## Branch and tag protection

Protection is configured with **repository rulesets**, never with legacy branch
protection, so it is inspectable through the API and exportable.

**K22-REPO-20 (MUST)** The default branch is named `main` and protected by a ruleset
named `protect-main` that:

- blocks deletion and force pushes;
- requires a pull request for every change (no direct pushes), with all review threads
  resolved before merging;
- requires the status checks listed in [CI/CD](ci-cd.md#required-checks) to pass, with
  the branch up to date with `main` before merging;
- requires linear history;
- requires signed commits.

With one maintainer, the required approval count is `0` and the automated review gate
of [`K22-SDLC-12`](../policies/sdlc.md#review) applies. With two or more maintainers it
is `1`, stale approvals are dismissed on push, and the last pusher cannot approve.
The ruleset has **no bypass actors**.
*Why:* every change to `main` is reviewed, tested, attributable, and reversible.
*Verified by:* conformance checker (ruleset API). *Maps to:* OSPS-AC-03.01,
OSPS-AC-03.02, OSPS-QA-03.01, OSPS-QA-07.01 (see exception EX-0001).

**K22-REPO-21 (MUST)** Release tags are protected by a ruleset named
`protect-release-tags` targeting `refs/tags/v*` that blocks creation by anyone but the
maintainer, and blocks deletion, update, and force push.
*Why:* a published version must always point at the same commit. *Verified by:*
conformance checker. *Maps to:* OSPS-BR-02.01.

**K22-REPO-22 (MUST)** Pull requests merge by **squash only**; the squash commit title
is the pull request title and its body the pull request body. Merged head branches are
deleted automatically.
*Why:* one reviewed change per commit on `main`, with a Conventional Commit title the
changelog can trust. *Verified by:* conformance checker (repository merge settings).

## Security settings

**K22-REPO-30 (MUST)** These GitHub security features are enabled: private vulnerability
reporting, secret scanning with push protection, Dependabot alerts, Dependabot security
updates, code scanning (CodeQL), and immutable releases.
*Why:* each is free on public repositories and closes a whole class of risk.
*Verified by:* conformance checker. *Maps to:* OSPS-VM-03.01, OSPS-BR-07.01.

**K22-REPO-31 (MUST)** GitHub Actions is configured so that the default `GITHUB_TOKEN`
is **read-only**, workflows cannot create or approve pull requests, and workflow runs
from first-time and outside contributors require approval.
*Why:* a compromised or malicious workflow starts with the least power possible.
*Verified by:* conformance checker (Actions permissions API). *Maps to:* OSPS-AC-04.01.

**K22-REPO-32 (SHOULD)** Allowed actions are restricted to GitHub-authored actions,
verified creators, and actions explicitly listed by the maintainer.
*Why:* limits the third-party code that can run with repository credentials.
*Verified by:* conformance checker (warning only).

## Repository hygiene

**K22-REPO-40 (MUST)** Issues are enabled on Product repositories as the public channel
for bugs, questions, and proposals; the wiki is disabled so documentation lives in
version control.
*Why:* public discussion of changes, and reviewed docs. *Verified by:* conformance
checker. *Maps to:* OSPS-GV-02.01, OSPS-DO-02.01.

**K22-REPO-41 (SHOULD)** The repository has a description and topics, and the
homepage points to documentation or the latest release.
*Why:* findability. *Verified by:* conformance checker (warning only).

**K22-REPO-42 (MUST)** The account-wide project inventory in
[`MAINTAINERS.md`](../MAINTAINERS.md#repositories) lists every Product repository.
*Why:* consumers can see every codebase that makes up KofTwentyTwo software and who has
access to it. *Verified by:* conformance checker (cross-check). *Maps to:*
OSPS-QA-04.01, OSPS-GV-01.01.
