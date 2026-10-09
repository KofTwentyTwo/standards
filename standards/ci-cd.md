# CI/CD standard

How KofTwentyTwo pipelines are built and secured. Pipelines run on **GitHub Actions**.
The reusable workflows in this repository implement most of these requirements;
calling them is the expected way to comply.

## Required checks

**K22-CI-01 (MUST)** Every pull request to `main` runs these checks, and the
`protect-main` ruleset ([`K22-REPO-20`](repository.md#branch-and-tag-protection))
requires all of them:

| Check (status context) | What it gates | Provided by |
| --- | --- | --- |
| `pr / title` | PR title is a valid [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/) header | `pr.yml` |
| `pr / dco` | Every commit carries a `Signed-off-by` matching its author | `pr.yml` |
| `pr / dependency-review` | No added dependency with a known vulnerability or a license outside the allowlist | `pr.yml` |
| `security / secrets` | No secret anywhere in the change or in history | `security.yml` |
| `security / sca` | No HIGH or CRITICAL vulnerability, and no package flagged as malicious (OSV `MAL-` advisories), in the resolved dependency graph | `security.yml` |
| `security / workflows` | Workflow files pass zizmor and actionlint | `security.yml` |
| `codeql / analyze (<language>)` | No CodeQL alert at *high* severity or above | `codeql.yml` |
| `ci / build-test` (.NET) | Locked restore, zero-warning build, tests, coverage gate | `dotnet.yml` |
| `ci / format` (.NET) | `dotnet format --verify-no-changes --severity warn`: Kingsrook layout, style, analyzers | `dotnet.yml` |
| `ci / ui-tests` (.NET apps with UI tests) | FlaUI end-to-end tests against the built app | `dotnet.yml` |
| Other languages | The language profile's build, test, coverage, and format commands | language workflow |

*Why:* the merge gate is the same in every repository and cannot be skipped.
*Verified by:* conformance checker (required contexts in the ruleset). *Maps to:*
OSPS-QA-03.01, OSPS-QA-06.01, OSPS-VM-05.03, OSPS-VM-06.02.

**K22-CI-02 (MUST)** CI runs the automated test suite on every pull request and every
push to `main`; a change that removes or skips tests needs a stated reason in the PR.
*Why:* nothing reaches `main` untested. *Verified by:* the language workflow; review.
*Maps to:* OSPS-QA-06.01.

**K22-CI-03 (MUST)** Every check runs the same commands a developer runs locally
(build, test, format, lint), documented in `CONTRIBUTING.md`. CI adds gates; it never
uses different settings that would make a local pass meaningless.
*Why:* fast feedback at the desk, no surprises in CI. *Verified by:* review.
*Maps to:* OSPS-QA-06.02.

## Workflow security

**K22-CI-10 (MUST)** Every workflow sets `permissions: {}` (or `contents: read`) at the
top level and grants each job only the scopes it uses.
*Why:* a compromised step can only do what its job was allowed to do. *Verified by:*
zizmor (`excessive-permissions`), conformance checker. *Maps to:* OSPS-AC-04.01,
OSPS-AC-04.02.

**K22-CI-11 (MUST)** Every third-party action is referenced by a full 40-character
commit SHA with the version in a trailing comment, for example
`uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`. Every
container image is referenced by digest. Dependabot keeps the action SHAs current;
container digests used inside workflows (which Dependabot does not track) are updated
with each release of this repository, and callers pick them up by updating their pin.
*Why:* tags are mutable; a hijacked tag is the most common Actions supply-chain attack.
*Verified by:* zizmor (`unpinned-uses`, `unpinned-images`), conformance checker.

**K22-CI-12 (MUST)** Untrusted input (pull request titles, bodies, branch names, commit
messages, issue text, artifact contents) is never interpolated into a `run:` script.
It is passed through an environment variable and treated as data.
*Why:* `${{ github.event.pull_request.title }}` inside `run:` is a shell injection.
*Verified by:* zizmor (`template-injection`). *Maps to:* OSPS-BR-01.01, OSPS-BR-01.04.

**K22-CI-13 (MUST)** Code from a pull request never runs with access to secrets or a
write token: `pull_request_target` and `workflow_run` are not used to check out or
execute pull request code, and workflows that handle untrusted code have no secrets.
*Why:* this is how fork pull requests steal credentials. *Verified by:* zizmor
(`dangerous-triggers`). *Maps to:* OSPS-BR-01.03.

**K22-CI-14 (MUST)** `actions/checkout` sets `persist-credentials: false` unless a later
step must push, and that job is documented.
*Why:* a token left in `.git/config` is readable by every later step. *Verified by:*
zizmor (`artipacked`).

**K22-CI-15 (MUST)** Release and publishing jobs do not restore caches.
*Why:* a poisoned cache written by a pull request run must never reach a release.
*Verified by:* zizmor (`cache-poisoning`).

**K22-CI-16 (MUST)** Long-lived secrets are avoided. Signing, package publishing, and
cloud access use OIDC federation where the service supports it (Azure Trusted Signing,
nuget.org trusted publishing, PyPI and npm trusted publishing). Any remaining secret
lives in a GitHub **environment** whose deployment rules allow only protected `v*` tags.
*Why:* nothing to leak, nothing to rotate, and secrets reachable only from a release.
*Verified by:* conformance checker (environments and secrets inventory); review.
*Maps to:* OSPS-BR-07.02.

**K22-CI-17 (MUST)** Product repositories run only on GitHub-hosted runners.
Self-hosted runners are never attached to a public repository.
*Why:* a public repository's pull requests would run arbitrary code on the host.
*Verified by:* conformance checker (runners API).

**K22-CI-18 (SHOULD)** Every job sets `timeout-minutes`, and workflows set
`concurrency` so superseded pull request runs are cancelled.
*Why:* hung jobs waste minutes and delay feedback. *Verified by:* actionlint (where
supported); review.

## Security scanning

**K22-CI-20 (MUST)** Secrets are scanned on every push and pull request with gitleaks
over the full history (fetch depth 0), in addition to GitHub push protection, and
locally in pre-commit.
*Why:* defense in depth; push protection does not cover every token format.
*Verified by:* `security / secrets`. *Maps to:* OSPS-BR-07.01.

**K22-CI-21 (MUST)** Software composition analysis (Trivy, filesystem mode, reading
the lock files) blocks HIGH and CRITICAL vulnerabilities, and runs on every pull
request, every push to `main`, and weekly so new advisories are caught between
changes. Results are uploaded to GitHub code scanning.
*Why:* vulnerabilities are published against code that has not changed.
*Verified by:* `security / sca`. *Maps to:* OSPS-VM-05.03.

**K22-CI-22 (MUST)** Static analysis (CodeQL with the `security-extended` query suite)
runs on every pull request and weekly for each supported language, and blocks alerts of
*high* severity or above.
*Why:* finds injection, path traversal, and unsafe deserialization before review does.
*Verified by:* `codeql / analyze`. *Maps to:* OSPS-VM-06.02.

**K22-CI-23 (MUST)** Workflow files are linted by zizmor (all audits, failing on
*medium* severity or above) and actionlint on every change.
*Why:* the pipeline is code with the most privilege in the repository.
*Verified by:* `security / workflows`.

**K22-CI-24 (SHOULD)** The OpenSSF Scorecard workflow runs weekly and on pushes to
`main`, publishing results.
*Why:* an independent, public measure of these practices. *Verified by:* Scorecard
badge.

## Release pipelines

**K22-CI-30 (MUST)** Releases are built only by a workflow triggered by a protected
`v*` tag, running on a GitHub-hosted runner, through a **reusable workflow** from
`KofTwentyTwo/standards` (`release-nuget.yml` for NuGet packages), so the build
platform and its definition are isolated from the calling repository. Publishing to a
registry whose trusted publishing binds the token to the calling repository's own
workflow file (nuget.org does) runs in a job of the caller's tag workflow, after it has
verified the artifacts' attestations were signed by the reusable workflow.
*Why:* this is what makes provenance trustworthy (SLSA Build L3). *Verified by:*
provenance `builder.id` names the reusable workflow; conformance checker (the tag
workflow calls `KofTwentyTwo/standards/.github/workflows/release-*.yml` pinned by SHA).
See [releases](releases.md).

**K22-CI-31 (MUST)** A release re-runs every gate that guards `main` (build, tests,
coverage, security scans) before publishing anything.
*Why:* a tag can only ship what CI would accept. *Verified by:* the release workflow.
