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
