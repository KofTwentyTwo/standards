# Standards bundle releases

The official distribution channel is
[GitHub Releases](https://github.com/KofTwentyTwo/standards/releases). Each stable
`vMAJOR.MINOR.PATCH` release contains ZIP and tar.gz archives of the **committed
repository**, with the directory layout intact, including hidden configurations,
licenses, workflows, templates, and tooling. Git metadata, untracked files, and
uncommitted edits are excluded. Extract either archive to use the standards offline
or copy its configs and templates into another repository.

## Semantic versions

[Release Please](https://github.com/googleapis/release-please) opens and updates a
release PR after successful `main` CI, changing `version.txt`, `CHANGELOG.md`, and
`.release-please-manifest.json`. The first proposal is `0.1.0`; `0.0.0` is the
unreleased bootstrap placeholder. The tag is the published version's authority; the files are checked
against it before packaging.

| Commit or squash PR title | Bump | Example |
| --- | --- | --- |
| `fix:`, `docs:`, `security:` | PATCH | `docs(testing): clarify coverage calculation` |
| `feat:` | MINOR | `feat(coding): add a language profile` |
| Any type with `!` or `BREAKING CHANGE:` | MAJOR | `feat(repository)!: require a new control` |

Use `feat` for new guidance and `!` for new obligations or removed allowances as
defined in [the versioning policy](../policies/README.md#versioning-of-the-standards).
Infrastructure changes appear in release notes and can produce PATCH releases;
`test`, `style`, and `chore` alone do not produce release notes. Review the proposed
version and notes before merging. A `breaking` label alone does not change the version.

## One-time maintainer setup

1. Keep **Settings → General → Releases → Enable release immutability** enabled.
   The publisher checks the setting before creating a release and refuses to proceed
   if it is disabled or unreadable. GitHub locks assets and the tag on publication;
   immutability applies to future releases, not retroactively.
2. Keep [EX-0006](../exceptions/register.md#ex-0006) open and unexpired before
   enabling version proposals. `K22-CI-16` otherwise restricts remaining secrets to
   tag-only environments; the release-PR bot needs a narrow main-only exception.
   Approval is recorded in the reviewed release-bundle implementation PR.
3. Create a GitHub App installed **only on this repository**, with Contents and Pull
   requests **write**, Administration **read**, and no ruleset bypass. Store its client
   ID in the Actions variable `RELEASE_APP_CLIENT_ID`. Short-lived App tokens let
   release PRs trigger CI; a PR made using `GITHUB_TOKEN` would not.
4. Configure `release-automation` with deployment access for `main` only, and
   `release` with a maintainer reviewer and deployment access for `v*` tags only.
   Store `RELEASE_APP_PRIVATE_KEY` separately in these **environment secrets**;
   never as a repository secret or committed file. Environments in the reusable
   publisher resolve their own secrets, but the caller must explicitly pass the
   secret name and the reusable workflow must declare it. The named contract does
   not expose the tag-only value to caller jobs or nested CI gates.
   Keep `protect-main` and `protect-release-tags` intact; the App does not create
   tags or bypass review. Allow the SHA-pinned Release Please action if repository
   action restrictions require an explicit allowlist entry.

No npm/NuGet publishing credential or registry package is required. Upstream App-token
and Release Please actions are pinned and tracked by Dependabot. See the
[distribution ADR](adr/0001-release-standards-bundles.md).

## Publish a version

1. Review the release PR, complete its CI and review gates, and squash-merge it.
2. For MINOR and MAJOR releases, complete the pre-tag checks in an issue made from
   [the release checklist](../templates/release-checklist.md). Attach the full
   conformance result and security assessment. PATCH releases still need conformance
   and scan results. Keep the README's draft/adoption status accurate before `v1.0.0`.
   Apply the maintainer-only `release: ready` label after sections 1–4 and the
   green-main/release-notes check in section 5 are complete. Leave publication checks
   unchecked until verified, then close the issue after shipping.
3. Tag the **release PR's merge commit** with its proposed version. Only the maintainer
   can create protected tags. For a MINOR or MAJOR, the annotation must contain
   `Release checklist: https://github.com/KofTwentyTwo/standards/issues/<number>`.

   ```bash
   git fetch origin main
   git tag -s v0.1.0 <release-pr-merge-sha> \
     -m "Release checklist: https://github.com/KofTwentyTwo/standards/issues/123"
   git push origin v0.1.0
   ```

4. The tag workflow validates ancestry, version files, the pending release PR, and
   the checklist; reruns all repository CI gates; builds and attests the assets;
   and waits for the `release` environment approval. Publication creates a draft with
   all assets and notes, then publishes it. The release PR is marked
   `autorelease: tagged` so the next version can be proposed. Version proposals wait
   while a merged release PR has `autorelease: pending`; a failed, permanently
   retired version uses `autorelease: failed` instead.

These bundles ship no compiled software, so the compiled-artifact SBOM requirement
does not apply. The included workflows/configs retain their upstream pins; source
provenance and checksums identify the published bundle.

## Verify and reproduce

Every release includes `KofTwentyTwo-standards-<version>.zip`, `.tar.gz`,
`.manifest.json`, `.notes.md`, and `SHA256SUMS`. The manifest records the exact commit
and license split. Download assets from a specific version, then verify:

```bash
gh release download v0.1.0 --repo KofTwentyTwo/standards --dir standards-0.1.0
cd standards-0.1.0
sha256sum --check SHA256SUMS
gh attestation verify KofTwentyTwo-standards-0.1.0.zip --repo KofTwentyTwo/standards
```

On Windows, compare `Get-FileHash -Algorithm SHA256` to the corresponding entry in
`SHA256SUMS`. Pin reusable workflow callers to the release's full commit SHA, with a
version comment; do not use a moving branch or tag as a workflow pin.

To reproduce from a checkout containing the release commit:

```powershell
pwsh tools/Build-StandardsPackage.ps1 -Version 0.1.0 -Ref v0.1.0 -OutputPath artifacts/rebuild-0.1.0
pwsh tools/Test-StandardsPackage.ps1
```

Use the original checklist URL with `-ChecklistUrl` to reproduce `.notes.md` and
`SHA256SUMS` exactly. ZIP and tar.gz output is deterministic for a commit using the
same Git/archive tool versions. The builder refuses an existing output directory.

## Failed releases

The initial `v0.1.0` tag was reserved by a workflow-startup failure; no bundle was
published for it. The `v0.1.1` publisher then stopped before draft creation because
the caller omitted the environment secret contract. Both tags remain reserved;
`v0.1.2` is the planned first published bundle. Keep these tags unchanged; use a new
version when a tagged workflow needs a source fix.

Never replace published assets or move/reuse a version tag. Fix a published error
with a new release. A failed upload or publication leaves a draft; inspect its run
and assets, then remove **only the unpublished draft** before rerunning the tag's
`standards-release` workflow using **Run workflow** with that tag selected. Keep the
tag unchanged. If publication succeeded but PR labeling failed, change the PR label
from `autorelease: pending` to `autorelease: tagged`; do not rebuild the release.

References: [GitHub immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases),
[enabling immutability](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/establish-provenance-and-integrity/prevent-release-changes),
and [Release Please token behavior](https://github.com/googleapis/release-please-action#other-actions-on-release-please-prs).
