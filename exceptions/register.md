# Exception register

Open and closed exceptions to the KofTwentyTwo standards. The process is in
[policies/exceptions.md](../policies/exceptions.md).

| ID | Status | Requirements | Scope | Expires |
| --- | --- | --- | --- | --- |
| [EX-0001](#ex-0001) | Open | K22-REPO-20 (approval count), OSPS-QA-07.01 | All repositories | When a second maintainer joins; reviewed 2027-10-09 |
| [EX-0002](#ex-0002) | Open | K22-REL-05 (Authenticode signing of Windows binaries) | Windows desktop apps (gclo, AppKit samples, future apps) | When the Azure Trusted Signing identity is validated, at the latest 2027-04-09 |

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
  even without a signature. **Current state:** gclo's existing releases have neither;
  they gain them when gclo moves to the shared release workflow.
- **Expires:** when the signing identity is validated and the shared release workflow
  signs Windows binaries; at the latest 2027-04-09.
- **Owner:** the maintainer.
