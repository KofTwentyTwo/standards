# Exception register

Open and closed exceptions to the KofTwentyTwo standards. The process is in
[policies/exceptions.md](../policies/exceptions.md).

| ID | Status | Requirements | Scope | Expires |
| --- | --- | --- | --- | --- |
| [EX-0001](#ex-0001) | Open | K22-REPO-20 (approval count), OSPS-QA-07.01 | All repositories | When a second maintainer joins; reviewed 2027-10-09 |
| [EX-0002](#ex-0002) | Open | K22-REL-05 (Authenticode signing of Windows binaries) | Windows desktop apps (gclo, AppKit samples, future apps) | When the Azure Trusted Signing identity is validated, at the latest 2027-04-09 |
| [EX-0003](#ex-0003) | Open | K22-DEP-02 (license allowlist) | gclo | Reviewed yearly, next on 2027-10-09 |
| [EX-0004](#ex-0004) | Open | K22-CI-30, K22-REL-04 (shared release workflow) | gclo | When the shared reusable release workflow ships, at the latest 2027-04-09 |
| [EX-0005](#ex-0005) | Open | K22-AI-10 (agents via PR only), K22-AI-11 (in part: unconfirmed pushes) | second-brain, nix, Praetor, Jellyfin | Reviewed yearly, next on 2027-10-10 |
| [EX-0006](#ex-0006) | Open | K22-CI-16 (tag-only environment secrets) | standards | 2027-04-10; review 2027-01-10 |
| [EX-0007](#ex-0007) | Open | K22-REPO-12 (enrollment) | KofTwentyTwo/standards | 2026-11-10; review 2026-10-17 |

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
  anti-spam restriction and explicitly deferred enrollment. No project ID exists.
- **Risk:** consumers cannot inspect a registered provider assessment yet.
- **Compensating controls:** publish the [criterion evidence](../docs/security/best-practices.md)
  and pending answers; retain existing security/PR gates and parser fuzzing. Do not
  claim participation or a passing badge. Retry normal login once the restriction
  clears, register the exact repository URL, and close this exception through a PR.
- **Expires:** 2026-11-10 (UTC), or successful enrollment and README badge publication,
  whichever occurs first. **Review:** 2026-10-17.
- **Owner:** @KofTwentyTwo. Approval is recorded by the normal exception-register PR;
  this entry does not authorize bypassing CI or publishing an unreviewed assessment.
