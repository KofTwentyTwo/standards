# Exception register

Open and closed exceptions to the KofTwentyTwo standards. The process is in
[policies/exceptions.md](../policies/exceptions.md).

| ID | Status | Requirements | Scope | Expires |
| --- | --- | --- | --- | --- |
| [EX-0001](#ex-0001) | Open | K22-REPO-20 (approval count), OSPS-QA-07.01 | All repositories | When a second maintainer joins; reviewed 2027-10-09 |
| [EX-0002](#ex-0002) | Open | K22-REL-05 (Authenticode signing of Windows binaries) | Windows desktop apps (gclo, AppKit samples, future apps) | When the Azure Trusted Signing identity is validated, at the latest 2027-04-09 |
| [EX-0003](#ex-0003) | Open | K22-DEP-02 (license allowlist) | gclo | Reviewed yearly, next on 2027-10-09 |
| [EX-0004](#ex-0004) | Open | K22-CI-30, K22-REL-04 (shared release workflow) | gclo | When the shared reusable release workflow ships, at the latest 2027-04-09 |

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
