# Exception register

Open and closed exceptions to the KofTwentyTwo standards. The process is in
[policies/exceptions.md](../policies/exceptions.md).

| ID | Status | Requirements | Scope | Expires |
| --- | --- | --- | --- | --- |
| [EX-0001](#ex-0001) | Open | K22-REPO-20 (approval count), OSPS-QA-07.01 | All repositories | When a second maintainer joins; reviewed 2027-10-09 |
| [EX-0002](#ex-0002) | Open (closed for gclo 2026-10-11) | K22-REL-05 (Authenticode signing of Windows binaries) | Windows desktop apps not yet on `sign: true` (AppKit samples, future apps) | When each app turns on `sign: true` in the shared release workflow, at the latest 2027-04-09 |
| [EX-0003](#ex-0003) | Open | K22-DEP-02 (license allowlist) | gclo | Reviewed yearly, next on 2027-10-09 |
| [EX-0004](#ex-0004) | Open | K22-CI-30, K22-REL-04 (shared release workflow) | gclo | When the shared reusable release workflow ships, at the latest 2027-04-09 |
| [EX-0005](#ex-0005) | Open | K22-AI-10 (agents via PR only), K22-AI-11 (in part: unconfirmed pushes) | second-brain, nix, Praetor, Jellyfin | Reviewed yearly, next on 2027-10-10 |
| [EX-0006](#ex-0006) | Open | K22-CI-16 (tag-only environment secrets) | standards | 2027-04-10; review 2027-01-10 |
| [EX-0007](#ex-0007) | Closed | K22-REPO-12 (enrollment) | KofTwentyTwo/standards | Closed 2026-10-10 |
| [EX-0008](#ex-0008) | Open | K22-CI-21 (HIGH dependency finding) | Website-Frontend, development-only braces 3.0.3 | 2026-11-10; review 2026-10-17 |
| [EX-0009](#ex-0009) | Open | K22-REPO-20 (linear history), K22-REPO-22 (squash only) | Website-Backend, Website-Frontend, Munitor, cluster-gitops | Reviewed yearly, next on 2027-10-12 |
| [EX-0010](#ex-0010) | Open | K22-CI-01, K22-CI-10 to K22-CI-24, K22-CI-30 (GitHub Actions gates and reusable workflows) | Website-Backend, Website-Frontend, Munitor | 2027-04-12; review 2027-01-12 |
| [EX-0011](#ex-0011) | Open | K22-CODE-TS-01, K22-CODE-SH-02 (Kingsrook 3-space layout) | Website-Frontend (TypeScript), Munitor (shell) | 2027-04-12; review 2027-01-12 |
| [EX-0012](#ex-0012) | Open | K22-CODE-TF-04 (state never committed), K22-CODE-TF-05 (no secrets in `.tfvars`) | Praetor | Reviewed yearly, next on 2027-10-12 |
| [EX-0013](#ex-0013) | Open | K22-DEP-02 automated license classification | QRun-IO/qbit-printing, unmodified H2 2.4.240 only | 2027-04-30 or any H2 version/license change, whichever occurs first |
| [EX-0014](#ex-0014) | Proposed, awaiting approval | K22-DEP-02 (Microsoft SDK terms and classification) | QRun-IO/qqq-print-agent, exact 15-package Windows SDK inventory below | 2027-04-30 or any reviewed version/license/scope change, whichever occurs first |
| [EX-0015](#ex-0015) | Proposed, awaiting approval | K22-DEP-02 (build-tool license classification) | QRun-IO/qqq-print-protocol and QRun-IO/qqq-print-agent, development-only `uri-js` 4.4.1 only | 2027-04-30 or any `uri-js` version/license/scope change, whichever occurs first |

## EX-0001

**Single maintainer: no non-author human approval**

- **Requirements:** `K22-REPO-20` requires one approving review once a project has two
  or more maintainers; OSPS Baseline `OSPS-QA-07.01` (Level 3) requires at least one
  non-author human approval before merging to the primary branch.
- **Scope:** every KofTwentyTwo repository.
- **Reason:** KofTwentyTwo has one maintainer. A required approval that only the author
  can give is either unsatisfiable or satisfied through an admin bypass, which would be
  worse: a bypass habit is exactly what branch protection exists to prevent.
- **Risk:** a defect or malicious change authored or introduced through the maintainer's
  account reaches `main` without a second human looking at it.
- **Compensating controls** (being put in place during adoption; until a repository
  passes the conformance checker these are the plan, not yet the state):
  - every change still goes through a pull request; no direct pushes and no bypass
    actors on `protect-main`;
  - an automated AI code review is posted on every pull request, and every finding must
    be resolved before merging ([`K22-SDLC-12`](../policies/sdlc.md#build));
  - CodeQL (`security-extended`), software composition analysis, secret scanning, and
    workflow linting are required checks;
  - signed commits and DCO sign-off make every commit attributable;
  - immutable releases and attested builds mean a malicious merge cannot quietly alter a
    published artifact.
- **Expires:** when a second maintainer is added; the ruleset then requires one
  approval. Reviewed yearly, next on 2027-10-09.
- **Owner:** the maintainer.

## EX-0002

**Windows binaries not yet Authenticode-signed**

- **Requirements:** `K22-REL-05` requires Windows executables and installers to be
  Authenticode-signed.
- **Scope:** Windows desktop applications released from KofTwentyTwo repositories.
- **Reason:** the Azure Trusted Signing account requires identity validation of the
  maintainer as an individual developer, which is in progress.
- **Risk:** users cannot tell a genuine installer from a modified one by its signature,
  and Windows SmartScreen warns on download.
- **Compensating controls:** once the shared release workflow ships, every release asset
  is listed in `SHA256SUMS` and carries a GitHub build-provenance attestation
  (`K22-REL-04`), so integrity and origin can be verified with `gh attestation verify`
  even without a signature. **Current state:** since v1.0.1-beta.1 every gclo release
  asset is listed in `SHA256SUMS` and attested (by gclo's own release workflow, see
  EX-0004); releases before that have neither.
- **Expires:** when the signing identity is validated and the shared release workflow
  signs Windows binaries; at the latest 2027-04-09.
- **Closed for gclo:** 2026-10-11. The signing identity (Azure Artifact Signing account
  `kof22signing`, Public Trust profile, publisher "James Maes") is validated and the
  shared workflow signs on `sign: true` (standards#28/#29): gclo v1.0.2-beta.3,
  v1.1.0-beta.1 and v1.1.0 ship Setup.exe, Update.exe and every exe/dll
  Authenticode-signed (SHA-256, RFC 3161), verified with `signtool verify /pa /all` by
  gclo's `verify-signatures` job and by hand (289 files, 0 failures). The exception
  stays open only for Windows apps that have not turned `sign: true` on yet.
- **Owner:** the maintainer.

## EX-0003

**gclo ships libgit2 (GPL-2.0 with linking exception) and the Microsoft Windows SDK packages**

- **Requirements:** `K22-DEP-02` requires shipped dependencies to carry an allowlisted
  license; any GPL variant needs a recorded exception.
- **Scope:** `KofTwentyTwo/gclo`: the NuGet packages `LibGit2Sharp` (MIT, bundling the
  native `libgit2` under GPL-2.0 *with the linking exception*, which permits linking
  from MIT code without GPL obligations), `Microsoft.WindowsAppSDK` (Microsoft
  Software License Terms, redistributable runtime), and
  `Microsoft.Windows.SDK.BuildTools` (Windows SDK license, build-time only). All three
  declare their license as a file, so GitHub's dependency graph reports them as
  `NOASSERTION`/`unknown` and the `pr / dependency-review` license check fails on any
  change to them.
- **Reason:** there is no alternative git implementation for .NET with libgit2's
  maturity, and a WinUI 3 app cannot exist without the Windows App SDK.
- **Risk:** none to users under the linking exception and Microsoft's redistribution
  terms; the risk is procedural (the automated license gate cannot evaluate them).
- **Compensating controls:** the three packages are named explicitly in the
  `allow-dependencies-licenses` input of `pr.yml`, so every other package still goes
  through the allowlist; vulnerability checks still apply to them; their terms are
  linked from gclo's README attributions.
- **Expires:** reviewed yearly, next on 2027-10-09.
- **Owner:** the maintainer.

## EX-0004

**gclo releases are built by an in-repository workflow until the shared release workflow exists**

- **Requirements:** `K22-CI-30` and `K22-REL-04` require releases to be built and
  attested by a reusable release workflow from this repository (SLSA Build L3).
- **Scope:** `KofTwentyTwo/gclo` (`.github/workflows/release.yml`).
- **Reason:** this repository does not yet publish a reusable release workflow; the
  requirement cannot be met by any caller until it does.
- **Risk:** the provenance's `builder.id` names gclo's own workflow rather than an
  isolated one, so a compromise of gclo's repository could alter the build definition
  and its attestation together (SLSA Build L2 rather than L3).
- **Compensating controls:** the release job is gated on a protected `v*` tag that
  must be on `main`, re-runs the CI gates, uses SHA-pinned actions and no caches,
  attests provenance and SBOMs through GitHub's OIDC-based attestation actions, and
  publishes immutable releases with `SHA256SUMS`.
- **Expires:** when the shared reusable release workflow ships and gclo calls it; at
  the latest 2027-04-09.
- **Owner:** the maintainer.

## EX-0005

**Agents push directly to personal-automation repositories**

- **Requirements:** `K22-AI-10` requires agents to work through pull requests only,
  never pushing to a repository's primary branch. `K22-AI-11` in part: in the
  repositories below, the agent permission mode auto-approves `git push` rather than
  confirming each one (destructive and protected operations are still confirmed, see
  compensating controls).
- **Scope:** the Internal-tier personal-automation repositories where an agent's
  direct push is the designed workflow: `KofTwentyTwo/second-brain` (agent memory
  vault, `main`), `KofTwentyTwo/nix` (machine configuration, `main`),
  `KofTwentyTwo/Praetor` (homelab infrastructure-as-code, `develop`), and
  `KofTwentyTwo/Jellyfin` (media-stack configuration and docs, `main`).
- **Reason:** these repositories are the agents' working medium, not reviewed product
  code. The vault is written as durable memory many times a day; the nix and Praetor
  repositories record machine and network state the operator has just applied and
  verified in the same session. With a single maintainer (EX-0001) a pull request per
  vault save or state snapshot would be self-merged seconds later — ceremony that
  trains bypass habits without adding a reviewer.
- **Risk:** a defective or manipulated agent commit lands on the primary branch
  without a pull-request gate: corrupted memory notes, a broken machine configuration,
  or drifted infrastructure definitions.
- **Compensating controls:**
  - the maintainer is present in the session and reviews the work product as it
    happens; every push is reported with its commit hash;
  - commits are signed through the 1Password SSH agent — a locked agent blocks
    commits entirely, so nothing is written unattended;
  - the destructive half of the IaC loop stays human-gated: the agent permission
    classifier blocks `tofu apply` with pending changes in Praetor, and plans must
    reach zero-drift;
  - the nix repository's quality gates (`scripts/check-repo.sh`) run before push;
  - the vault has a weekly consolidation job and retrieval eval auditing content
    quality, and full git history makes any save revertible;
  - no Product-tier repository is covered: product code still goes through pull
    requests per `K22-AI-10`.
- **Expires:** reviewed yearly, next on 2027-10-10.
- **Owner:** the maintainer.

## EX-0006

**Main-only release-version bot credential**

- **Status:** Open; approved with the reviewed release-bundle implementation PR.
- **Requirements:** `K22-CI-16` restricts remaining secrets to environments whose
  deployment rules allow only protected `v*` tags.
- **Scope:** `KofTwentyTwo/standards`, only `RELEASE_APP_PRIVATE_KEY` in the
  `release-automation` environment for the `ci.yml` release-PR job on protected `main`.
- **Reason:** Release Please needs a GitHub App token to create version PRs that
  trigger CI without enabling PR creation by `GITHUB_TOKEN`. No native GitHub App
  OIDC exchange is configured; the private key is therefore needed before a tag exists.
- **Risk:** compromised version-PR automation could obtain the App key and exercise
  the App's repository permissions.
- **Compensating controls:** App installation limited to this repository; Contents and
  Pull requests write, Administration read only; no ruleset bypass; main-only
  environment deployment policy; job runs only after all main CI gates succeed;
  SHA-pinned actions; short-lived scoped installation tokens revoked after each job;
  all resulting PRs still require normal checks and maintainer review. The bot neither
  creates release tags nor signs or publishes packages. Publication still uses the
  protected tag-only `release` environment and GitHub's immutable-releases setting.
- **Expires:** 2027-04-10, or earlier when version proposals use credential federation.
- **Owner:** the maintainer.
- **Review date:** 2027-01-10.

## EX-0007

**Best Practices enrollment temporarily blocked by provider anti-spam**

- **Requirements:** `K22-REPO-12` enrollment and the actual README badge only.
- **Scope:** `KofTwentyTwo/standards`; no downstream repository is covered.
- **Reason:** on 2026-10-10 the maintainer could not sign in because of the provider's
  anti-spam restriction and explicitly deferred enrollment. No project ID existed
  when this exception was approved.
- **Risk:** consumers could not inspect a registered provider assessment during the
  enrollment deferral.
- **Compensating controls (while open):** publish the [criterion evidence](../docs/security/best-practices.md)
  and pending answers; retain existing security/PR gates and parser fuzzing. Do not
  claim participation or a passing badge. Retry normal login once the restriction
  clears, register the exact repository URL, and close this exception through a PR.
- **Expires:** 2026-11-10 (UTC), or successful enrollment and README badge publication,
  whichever occurs first. **Review:** 2026-10-17.
- **Owner:** @KofTwentyTwo. Approval is recorded by the normal exception-register PR;
  this entry does not authorize bypassing CI or publishing an unreviewed assessment.
- **Closed:** 2026-10-10. [Project 15366](https://www.bestpractices.dev/projects/15366)
  identifies this repository and has earned the passing badge. The actual linked
  badge is in [README](../README.md), the project URL is in
  [assurance.json](../docs/security/assurance.json), and the
  [assessment record](../docs/security/best-practices.md) sets the next review date.

## EX-0008

**Temporary development dependency audit exception for Website-Frontend**

- **Requirements:** `K22-CI-21` blocks HIGH and CRITICAL findings in the resolved
  dependency graph.
- **Scope:** `KofTwentyTwo/Website-Frontend` only; development-only `braces` 3.0.3,
  [GHSA-vfj7-8cjw-p6xm](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm)
  / CVE-2026-93687 and npm's propagated findings for that same advisory. No other
  advisory, runtime dependency or CRITICAL finding is covered.
- **Reason:** the Next ESLint tooling depends on the affected package and no patched
  npm release exists as of 2026-10-10. npm suggests an unrelated parent downgrade;
  that does not establish a patched braces release.
- **Risk:** a deliberately deeply nested caller-supplied brace pattern can exhaust
  the stack and stop a lint/build process. Website requests and article Markdown do
  not control the lint glob configuration. The dependency remains vulnerable.
- **Compensating controls:** the complete audit still runs. A separate production
  audit must have zero HIGH/CRITICAL findings. The exception checker validates the
  advisory ID, package, locked version, development-only package paths and expiry;
  rejects other HIGH/CRITICAL findings, malformed reports and audit errors; and
  requires reassessment if the registry reports a new braces release. Lint, tests,
  build, secret scanning, SAST and Trivy remain enabled. No global scanner exclusion
  is permitted. Website-Frontend configuration cites this ID.
- **Expires:** 2026-11-10 at 00:00 UTC, or a patched upstream release, whichever
  occurs first. A newer upstream release blocks acceptance pending reassessment.
- **Owner:** James Maes, repository maintainer.
- **Review date:** 2026-10-17. Remove the consumer exception and close this entry once
  the affected dependency is replaced or patched.

## EX-0009

**GitFlow with merge commits for Munitor-released and GitOps repositories**

- **Requirements:** `K22-REPO-20` (linear history on `main`) and `K22-REPO-22`
  (squash-only merges).
- **Scope:** `KofTwentyTwo/Website-Backend`, `KofTwentyTwo/Website-Frontend`,
  `KofTwentyTwo/Munitor` (`develop` and `main`, `feature/*` and `hotfix/*` branches)
  and `KofTwentyTwo/cluster-gitops` (`main`, merge commits).
- **Reason:** these repositories run GitFlow with merge commits. In Website-Backend
  and Website-Frontend, `feature/*` and `hotfix/*` branches (and `develop`
  promotions) merge to `main`, which releases and deploys through Munitor, and a
  `main` to `develop` back-merge follows. Munitor itself merges `feature/*` into
  `develop`, `release/X.Y.Z` into `main`, back-merges `main` into `develop`, and a
  `vX.Y.Z` tag publishes the orb. Squash
  or rebase merges break the ancestry between `develop` and `main` that the pipeline
  relies on. cluster-gitops keeps merge commits so each change set applied by ArgoCD
  stays one reviewable unit next to the automated image-bump commits.
- **Risk:** non-linear history is harder to bisect and to read, and a merge commit can
  carry several commits that were never reviewed individually.
- **Compensating controls:** every human change to the Website repositories and
  Munitor reaches `main` through a pull request; repository rulesets require signed
  commits and the CircleCI checks on `main` and `develop`. cluster-gitops (Internal
  tier, no CI) requires signed commits and blocks deletion and force pushes on `main`;
  the Munitor deploy step writes image bumps to it directly as GitHub-signed commits
  (GraphQL `createCommitOnBranch`), with no bypass actor; release tags stay protected
  (`K22-REPO-21`); merged branches are deleted.
- **Expires:** reviewed yearly, next on 2027-10-12, or earlier if Munitor gains a
  squash-compatible release mode.
- **Owner:** the maintainer.

## EX-0010

**CircleCI instead of the GitHub Actions reusable workflows**

- **Requirements:** `K22-CI-01` (required checks run by the reusable workflows),
  `K22-CI-10` to `K22-CI-24` as written for GitHub Actions, and `K22-CI-30`
  (releases built by the shared reusable release workflow).
- **Scope:** `KofTwentyTwo/Website-Backend`, `KofTwentyTwo/Website-Frontend` and
  `KofTwentyTwo/Munitor` (the CircleCI orb that builds, releases and deploys them).
- **Reason:** these repositories build, publish container images and deploy to the
  k8s-galaxy cluster through the Munitor CircleCI orb, which predates the reusable
  GitHub Actions workflows and holds the deploy integration (image publishing,
  cluster-gitops version bumps). Porting the pipeline is a separate project.
- **Risk:** the gates are implemented per orb rather than by the audited reusable
  workflows, so a gate can be missing or weaker than the standard (for example
  CodeQL, zizmor, Scorecard and SLSA provenance have no CircleCI equivalent here).
- **Compensating controls:** the CircleCI checks are required by the repository
  rulesets (Website: `build-and-test`, `secrets-scan`, `sast-scan`; Munitor:
  `orb-tools/lint`, `pack`, `review`, `test`); the orb runs the test suite, gitleaks and Trivy where configured;
  GitHub-side controls still apply (secret scanning with push protection, Dependabot
  alerts and security updates, code scanning default setup where available); orbs are
  pinned to exact versions; signed commits are required.
- **Expires:** 2027-04-12, or when the repositories move to the reusable workflows;
  review 2027-01-12.
- **Owner:** the maintainer.

## EX-0011

**Website-Frontend and Munitor keep 2-space formatting**

- **Requirements:** `K22-CODE-TS-01` (Kingsrook layout through the KofTwentyTwo ESLint
  configuration: 3-space indent, Allman braces) and `K22-CODE-SH-02` (3-space shell
  indentation).
- **Scope:** `KofTwentyTwo/Website-Frontend` TypeScript, JavaScript, CSS and JSON
  sources; `KofTwentyTwo/Munitor` Bash scripts and templates.
- **Reason:** the Next.js code base was written in the framework's default 2-space
  layout and is formatted by Prettier 3 (with `prettier-plugin-tailwindcss`) plus
  ESLint 9 with `eslint-config-next`, which the TypeScript profile does not use.
  Munitor's 100+ orb scripts and templates use 2-space indentation. Reformatting
  either is a large whitespace-only diff that triggers releases (a Website deploy or
  a new orb version for every consumer) and obscures history.
- **Risk:** inconsistent layout across KofTwentyTwo TypeScript code; no functional
  risk.
- **Compensating controls:** `.editorconfig` comes from the standard, with only the
  indent size overridden for these file types and a comment citing this exception;
  the existing lint, type and orb checks still gate CI.
- **Expires:** 2027-04-12, or when the code base is reformatted and adopts
  `configs/typescript/eslint.config.mjs` (Website-Frontend) and the orb scripts are
  reformatted with shfmt (Munitor); review 2027-01-12.
- **Owner:** the maintainer.

## EX-0012

**Praetor commits git-crypt-encrypted OpenTofu state and variable files**

- **Requirements:** `K22-CODE-TF-04` (state is never committed; remote state with
  locking and encryption) and `K22-CODE-TF-05` (no secrets in `.tfvars` files).
- **Scope:** `KofTwentyTwo/Praetor` (Internal tier, private): the local-backend roots
  under `terraform/` and `unifi/` (17 `*.tfstate*` files) and their 10 `*.tfvars`
  files.
- **Reason:** Praetor provisions the homelab that would host any remote state backend
  (the cluster, the NAS and Infisical are themselves managed here), so a remote backend
  creates a bootstrap dependency on the infrastructure it builds. Committed, encrypted
  local state is the recovery path when that infrastructure is down.
- **Risk:** state and variable files contain credentials; anyone holding the git-crypt
  key or a decrypted clone can read them. Local state has no locking, so two
  concurrent applies could corrupt it.
- **Compensating controls:** `.gitattributes` encrypts every `*.tfstate*`, `*.tfvars*`,
  kubeconfig, talosconfig and `*secret*` path with git-crypt (GPG key held by the
  maintainer); `git-crypt status` reports no unencrypted secret files; the repository
  is private; applies are human-gated by the maintainer in session (`EX-0005`), which
  serializes them; secrets are moving into Infisical with `sensitive = true` outputs.
- **Expires:** reviewed yearly, next on 2027-10-12, or when the roots move to an
  encrypted remote backend.
- **Owner:** the maintainer.

## EX-0013

**H2 2.4.240 license metadata classification in QQQ Printing**

- **Requirements:** `K22-DEP-02` permits MPL-2.0 when used unmodified. This is an exception to the automated dependency-review classification for one already-permitted dependency, not permission to introduce an incompatible license or skip vulnerability review. The pinned `pr.yml` input requires this register entry for a package-specific license exception.
- **Scope:** `QRun-IO/qbit-printing` only; Maven package `com.h2database:h2`, unmodified version **2.4.240**, runtime JAR SHA-256 `29b70e427cc1c40cdc376283adbb0cc62853073797bb5fe5761f81fe73d57ce0`. No other package, version, repository or modified H2 binary is covered.
- **Reason:** GitHub dependency review reports `LicenseRef-scancode-unknown AND MPL-2.0`. The tagged upstream license expressly offers MPL-2.0 **or** EPL-1.0; this runtime uses the MPL-2.0 option. Published 2.3.232 and 2.4.240 POMs declare the same terms. Upgrading to 2.4.240 fixes confirmed close-time compaction data loss; reverting to the older driver is not an acceptable metadata workaround.
- **Risk:** The scanner cannot accurately classify this artifact's license. A package-level exclusion could otherwise hide a later license change because the pinned action ignores PURL versions. The reviewed binary remains unmodified and retains its license/attribution; this record does not waive the applicable redistribution terms.
- **Compensating controls:** The caller passes only `pkg:maven/com.h2database/h2` to `allow-dependencies-licenses`; every other package retains its existing license checks. The required `security / sca` Maven inventory guard rejects missing H2, any version other than 2.4.240, and multiple H2 versions, then verifies the complete selected runtime graph against scanner inventories. The runtime payload verifies every copied JAR's SHA-256 and contains exactly one H2 driver. The POM pins the reviewed version. `license-check: true`, `vulnerability-check: true`, low-or-higher dependency advisory review, Trivy severity gates, OSV malicious-package checks and all existing required checks remain enabled. H2 attribution and corresponding source access are documented in NOTICE and the repository license review. Any H2 upgrade requires renewed license review and guard/record updates before release.
- **Expires:** 2027-04-30, or an H2 version/license change or correction of GitHub's metadata classification, whichever occurs first. Remove or renew through the normal standards PR process; do not broaden the exclusion silently.
- **Owner:** the maintainer of `QRun-IO/qbit-printing`.
- **Review date:** 2026-10-30.
- **Evidence:** [H2 tagged license](https://github.com/h2database/h2database/blob/version-2.4.240/LICENSE.txt), [tagged license FAQ](https://github.com/h2database/h2database/blob/version-2.4.240/h2/src/docsrc/html/license.html), [published 2.4.240 POM](https://repo.maven.apache.org/maven2/com/h2database/h2/2.4.240/h2-2.4.240.pom), [published 2.3.232 POM](https://repo.maven.apache.org/maven2/com/h2database/h2/2.3.232/h2-2.3.232.pom), [failed dependency-review run](https://github.com/QRun-IO/qbit-printing/actions/runs/41160240342), [upstream compaction fix](https://github.com/h2database/h2database/pull/4249), [pinned workflow input](https://github.com/KofTwentyTwo/standards/blob/fdf5ed029603c938615a32b1beca3628b8787945/.github/workflows/pr.yml), [pinned version-ignoring matcher](https://github.com/actions/dependency-review-action/blob/a1d282b36b6f3519aa1f3fc636f609c47dddb294/src/purl.ts).

## EX-0014

**Exact Microsoft Windows SDK dependencies in QQQ Print Agent**

- **Status:** Open upon merge of this record through the normal protected PR process. The maintainer accepted the complete 15-package scope and its Microsoft custom terms on 2026-11-01; the earlier two-package proposal is superseded.
- **Requirements:** `K22-DEP-02`, for the Microsoft terms outside the standard license allowlist and their automated classification. This is not merely a metadata correction for an already-permitted SPDX license. No vulnerability, provenance, signing, attestation or branch-protection requirement is waived.
- **Scope:** `QRun-IO/qqq-print-agent` only, unmodified Windows x64 use of the exact package/version/raw-NUPKG-SHA-256 tuples below, including the source-linked native test host. BuildTools and MSIX tooling remain build-only. The implicit SDK reference pack also supplies reviewed runtime projections. No other repository, package, version, modified binary, standalone SDK offering, optional execution provider/model or new AI feature is covered. The finite table is authoritative; there is no Microsoft package-family wildcard.
- **Reason:** The existing WinUI application and its native regression host require this established SDK dependency set. Evaluated NuGet dependency submission now exposes the actual versions and non-SPDX Microsoft license terms. Removing declarations or returning to incomplete `>=0` metadata would hide dependencies rather than resolve the policy issue. AppKit's MIT dependencies retain ordinary license review and are not exempted.
- **Risk:** Microsoft's usage, redistribution, data/privacy/export and third-party obligations remain applicable. A package-name license exception could hide later version/license changes because the pinned action ignores PURL version constraints. Approval does not relicense Microsoft code as MIT or certify that every redistribution obligation has been satisfied.
- **Compensating controls:** The caller may list only the 15 exact package names below as `pkg:nuget/<name>` in `allow-dependencies-licenses`, after this record is approved. The required `Test-WindowsSdkInventory.ps1` guard checks exact versions, committed NuGet content hashes, raw package SHA-256, license/notice entry hashes and the corresponding explicit manifest. Raw signed-archive SHA-512 and NuGet lock `contentHash` are distinct and are checked separately. Fourteen packages are checked in app/test-host locks; `Microsoft.Windows.SDK.NET.Ref` is checked through evaluated SDK assets/download dependencies, not a fabricated lock entry. Preserve the five distinct license documents and applicable third-party notices. Verify BuildTools/MSIX nonlegal files are excluded and only expected runtime/projection output is distributed. Maintain explicit third-party terms and distributor/end-user protection obligations; generic MIT attribution alone is not sufficient. `license-check: true`, `vulnerability-check: true`, low-or-higher advisory failure, SCA/malware checks, locked restores, signed/DCO commits, required PR gates and release attestations remain enabled. Any reviewed version/license/payload-scope change requires renewed approval before the exclusion can be used.
- **Expires:** 2027-04-30, or any reviewed package version/license/scope change, whichever occurs first. A classifier improvement alone does not make proprietary terms permissively licensed; remove or renew the record through the normal standards PR process.
- **Owner:** the maintainer of `QRun-IO/qqq-print-agent`.
- **Review date:** 2026-11-01.

### Exact package scope

| NuGet package | Version | Raw NUPKG SHA-256 |
| --- | --- | --- |
| [Microsoft.Windows.AI.MachineLearning](https://www.nuget.org/packages/Microsoft.Windows.AI.MachineLearning/2.1.74) | 2.1.74 | `691165FA3C07A04B752CBF4A07E93ED13A418E9DEA1EE89EB163D2225E2BA3AF` |
| [Microsoft.Windows.SDK.BuildTools](https://www.nuget.org/packages/Microsoft.Windows.SDK.BuildTools/10.0.28000.2705) | 10.0.28000.2705 | `8BFDFB6CA2633F531CF80B5FA22512BA61A394D7988F0970DB83BAADC67929ED` |
| [Microsoft.Windows.SDK.BuildTools.MSIX](https://www.nuget.org/packages/Microsoft.Windows.SDK.BuildTools.MSIX/1.7.251221100) | 1.7.251221100 | `E61C560805029F5AE15433BE52E153F3862B6FAAF725292638A9ECE592F7A060` |
| [Microsoft.Windows.SDK.NET.Ref](https://www.nuget.org/packages/Microsoft.Windows.SDK.NET.Ref/10.0.19041.57) | 10.0.19041.57 | `90B18F2CF7D7A23F5B0BFE2B86D8DDA45881481F677CE36ECCAF6E9AB50B6B4B` |
| [Microsoft.WindowsAppSDK](https://www.nuget.org/packages/Microsoft.WindowsAppSDK/2.5.1) | 2.5.1 | `2E26DE1253E2E2A288A75387523E2F8B402C05F117D42013DF9875887A70933A` |
| [Microsoft.WindowsAppSDK.AI](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.AI/2.5.5) | 2.5.5 | `108143AD35B20C8DF7A885995CE4258E7C2E6BA74C9B60D2D819CBC46980B6FB` |
| [Microsoft.WindowsAppSDK.Base](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.Base/2.0.4) | 2.0.4 | `E3E13478C4C80C59ED5F8F89542FE49A2985DAA484753E93A5858E90C2D46A4D` |
| [Microsoft.WindowsAppSDK.DWrite](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.DWrite/2.1.0) | 2.1.0 | `91746ABD6A780B84001F9C465507830D5A24C79912BC4AA0D35938C71C1C6B5F` |
| [Microsoft.WindowsAppSDK.Foundation](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.Foundation/2.3.12) | 2.3.12 | `CE04D01D68CB16B5DC85A5C9EFB8162DBA876BC2E5B766B5968979899D4EFA9E` |
| [Microsoft.WindowsAppSDK.InteractiveExperiences](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.InteractiveExperiences/2.1.9) | 2.1.9 | `F9159D73E3E46717F159606E43B4ACF8336AAFF5BDD4D395FE3A93FDB41437AC` |
| [Microsoft.WindowsAppSDK.ML](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.ML/2.1.94) | 2.1.94 | `549E92CD397B9D90EA9F08334DB6C79DFA78FC49B47BD3D26A53EB1DF2F21191` |
| [Microsoft.WindowsAppSDK.Runtime](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.Runtime/2.5.1) | 2.5.1 | `2FBD27012291BE50CAFED6942306964281D37167AF6A6AF3887E1163EC5CF063` |
| [Microsoft.WindowsAppSDK.Search](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.Search/2.5.5) | 2.5.5 | `B5876FE0091A6A14C34E46B5BC898621E80B5ED598F45574B90DEB84BF33F023` |
| [Microsoft.WindowsAppSDK.Widgets](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.Widgets/2.0.5) | 2.0.5 | `7F1B585EF8F012784D2CB91B86E809814CECCAB74183A5979EF45DB141779CB5` |
| [Microsoft.WindowsAppSDK.WinUI](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.WinUI/2.3.9) | 2.3.9 | `D36145BD6C0F46FC04E07FB4AF365D093FB42C39B625948D0EAD07A0B26FCE96` |

The 14 ordinary packages have identical versions and NuGet content hashes in the production app and test host. `Microsoft.Windows.SDK.NET.Ref` is an implicit SDK download dependency; its reviewed `lib/net8.0/Microsoft.Windows.SDK.NET.dll` and `lib/net8.0/WinRT.Runtime.dll` are legitimate runtime projections, not build tools. Packaging verification found these bytes unchanged in the app, CLI and service; the package's `Microsoft.Windows.UI.Xaml.dll` was absent. The package manifest and payload guard retain these distinctions rather than excluding every reference-pack file indiscriminately.

### License evidence and conditions

| Exact document | Packages | License byte SHA-256 |
| --- | --- | --- |
| [Windows App SDK license.txt](https://www.nuget.org/packages/Microsoft.WindowsAppSDK/2.5.1/License) | WindowsAppSDK, AI, Base, DWrite, Foundation, InteractiveExperiences, Runtime, Search, Widgets, WinUI | `5B11E6347756E40FE0274BC08C97F89201B94F0D50181A09A00F1F4740840501` |
| [Windows App SDK and Windows ML license.txt](https://www.nuget.org/packages/Microsoft.WindowsAppSDK.ML/2.1.94/License) | WindowsAppSDK.ML 2.1.94 | `656AAB74C15AA9F9964BCDCC993EB2755CBDB4822D5E0E3BC61D2E281897F758` |
| [Windows ML Runtime license.txt](https://www.nuget.org/packages/Microsoft.Windows.AI.MachineLearning/2.1.74/License) | Windows.AI.MachineLearning 2.1.74 | `66395F8CB219087FAE2BD025010BD9076B736C14F03B48F20295471C0C376814` |
| [Packaged SDK sdk_license.txt](https://www.nuget.org/packages/Microsoft.Windows.SDK.BuildTools.MSIX/1.7.251221100/License) | SDK.BuildTools.MSIX 1.7.251221100 | `A7A5C7E7FF998558983D6ACA2702117C328AEB0C6404D298CB275F5623C6FD13` |
| [Official SDK license RTF](https://download.microsoft.com/download/0/F/F/0FF2B061-47DD-4F55-89B6-FD1D8C44F14D/sdk_license.rtf) | SDK.BuildTools and SDK.NET.Ref, whose nuspecs declare [WinSDKLicenseURL](https://aka.ms/WinSDKLicenseURL) | `DD07EB178E00C6BBA4148457FC00FF77CD4887EB521D504186FE59C9EC8BBE62` |

The 13 file-declared licenses were read from the exact package archives and their byte hashes checked. The two URL declarations resolved on 2026-10-31 to the official RTF above, labeled Windows 10 SDK / `WIN10SDK.RTM.AUG_2018_en-US`; that is the document supplied by these packages, not a guessed newer license. No full vendor-license copies are placed in this standards repository.

App SDK section 1 permits Windows development/testing; section 3 permits distribution of files placed with the application by the SDK, including self-contained deployment. Its requirements include significant application functionality, protective distributor/end-user terms, the stated indemnity obligations and unmodified-code exception, notices and restrictions on endorsement/standalone offerings. Both ML documents additionally retain their section 1(d) third-party-material/execution-provider terms. SDK sections 1(a)/1(c) cover development and build-server use; section 2 separately restricts redistributable/setup/utility code. These obligations and applicable third-party notices remain in force. The maintainer must fulfill the applicable redistribution/end-user protection requirements; this record is not a legal opinion or a waiver of vendor terms.

The paired guard passed 25 rejection tests and checked the actual package cache, 11 locks and 11 evaluated assets. An unexecuted local MSI (`F08FF820CB4F7EA3877554E27208441942C6AA4D8749AD5A0D852C21A14D814C`) was built and statically extracted: all 13 legal/manifest paths matched expected bytes, the two runtime projections matched their package bytes, and BuildTools/MSIX nonlegal payloads and other reference-pack bytes were excluded. This is technical packaging evidence, not a certification that every redistribution obligation is fulfilled or authorization to install/publish that local MSI.

Additional evidence: [resolved dependency-review failure](https://github.com/QRun-IO/qqq-print-agent/actions/runs/41259093183), [application change under review](https://github.com/QRun-IO/qqq-print-agent/pull/10), [pinned reusable workflow](https://github.com/KofTwentyTwo/standards/blob/fdf5ed029603c938615a32b1beca3628b8787945/.github/workflows/pr.yml), [version-ignoring package matcher](https://github.com/actions/dependency-review-action/blob/a1d282b36b6f3519aa1f3fc636f609c47dddb294/src/purl.ts). Publication and approval links must be added only when they exist.

## EX-0015

**uri-js 4.4.1 license classification in the QQQ Print build tooling**

- **Status:** Open upon merge of this record through the normal protected PR process.
- **Requirements:** `K22-DEP-02`. Build-only tools may use any OSI-approved license. GitHub dependency review classifies the npm package `uri-js` 4.4.1 as `BSD-2-Clause AND BSD-2-Clause-Views`, and SPDX lists `BSD-2-Clause-Views` as not separately OSI-approved. This is a classification exception for one build-only tool dependency, not permission to ship it and not permission to admit any other non-allowlisted license. No vulnerability, malware, provenance, signing or branch-protection requirement is waived.
- **Scope:** `QRun-IO/qqq-print-protocol` and `QRun-IO/qqq-print-agent` only; npm package `uri-js`, unmodified version **4.4.1**, lock integrity `sha512-7rKUyy33Q1yc98pQ1DAmLtwX109F7TIfWlW1Ydo8Wl1ii1SeHieeh0HHfPeL2fMXK6z0s8ecKs9frCuLJvndBg==`, installed `LICENSE` SHA-256 `0AF366EFF4C01EC147C9C61EA9E8FFAD64A4294754C9D79355F3FD1B97CB2FB9`. It is a locked, `dev: true`, transitive dependency of the pinned ESLint 10.14.0 (through ajv 6), never a direct dependency and never a runtime dependency. `node_modules` is restored only in development and CI; the protocol release bundle names repository paths only and the agent installer is built from .NET projects. No other package, version, repository or modified copy is covered.
- **Reason:** the pinned ESLint requires ajv 6, which requires `uri-js`; ESLint is required by the TypeScript standard for these repositories' owned tooling. The installed `LICENSE` (Copyright 2011 Gary Court) is the BSD-2-Clause conditions and disclaimer plus one sentence stating that the software's views and conclusions are the authors' and are not official policies; SPDX describes this as identical to BSD-2-Clause plus that sentence. It adds no restriction on use, copying, modification or redistribution. Replacing the resolver with a non-compatible library, or removing the package from the lock without an upstream ESLint change, would change reviewed tool behavior rather than resolve a policy problem.
- **Risk:** the scanner and SPDX classification are not on the permissive allowlist; the package is old (OpenSSF Scorecard 2.4, below the threshold of 3, already reported as a warning). A package-name exclusion could hide a later version or license change because the pinned action ignores PURL versions. Dependency review reports no vulnerability for 4.4.1.
- **Compensating controls:** each caller passes only `pkg:npm/uri-js` to `allow-dependencies-licenses`; every other package keeps its license check. `license-check: true`, `vulnerability-check: true`, low-or-higher advisory failure, development/runtime/unknown scopes, SCA/malware, Scorecard reporting and all required checks remain enabled. The required script-quality job in each repository fails unless the lock contains exactly one `uri-js`, version 4.4.1 with the integrity above, `dev: true`, not a direct dependency, required only by development packages; the installed `LICENSE` bytes hash to the value above; and the caller lists exactly `pkg:npm/uri-js` and no other npm package URL. The guard has rejection tests for another version, integrity, scope, consumer, duplicate copy, changed license bytes and a broadened caller list. Any version, license or scope change requires renewed approval before the exclusion can be used.
- **Expires:** 2027-04-30, or any `uri-js` version, license or scope change, or an ESLint release that no longer requires it, whichever occurs first. Remove or renew through the normal standards PR process; do not broaden the exclusion silently.
- **Owner:** the maintainer of `QRun-IO/qqq-print-protocol` and `QRun-IO/qqq-print-agent`.
- **Review date:** 2027-01-31.

Evidence: failed `pr / dependency-review` runs on [qqq-print-protocol#16](https://github.com/QRun-IO/qqq-print-protocol/pull/16) and [qqq-print-agent#18](https://github.com/QRun-IO/qqq-print-agent/pull/18) (only this license finding remained), [SPDX BSD-2-Clause-Views](https://spdx.org/licenses/BSD-2-Clause-Views.html), [pinned reusable workflow](https://github.com/KofTwentyTwo/standards/blob/fdf5ed029603c938615a32b1beca3628b8787945/.github/workflows/pr.yml), [version-ignoring package matcher](https://github.com/actions/dependency-review-action/blob/a1d282b36b6f3519aa1f3fc636f609c47dddb294/src/purl.ts).
