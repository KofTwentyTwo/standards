# Release standard

How KofTwentyTwo versions, builds, signs, attests, publishes, supports, and documents
releases. Releases are built only by the shared release workflows in this repository
([`K22-CI-30`](ci-cd.md#release-pipelines)).

## Versioning

**K22-REL-01 (MUST)** Releases use [Semantic Versioning 2.0](https://semver.org) and
are tagged `vMAJOR.MINOR.PATCH` on a commit of `main` (or of a supported
`release/<major>.<minor>` branch). A version with a prerelease suffix
(`v1.4.0-beta.2`) is a prerelease and is published on the prerelease channel. The tag
is the single source of the version; build files hold only the next expected version
for local builds. A version number is never reused, even after a release is withdrawn.
*Why:* a version identifies exactly one build, forever. *Verified by:* release workflow
tag validation; `protect-release-tags` ruleset. *Maps to:* OSPS-BR-02.01.

**K22-REL-02 (MUST)** Every release is a GitHub Release with notes generated from the
Conventional Commit titles merged since the previous release, grouped by type, with
breaking changes and security fixes (with advisory links) listed first.
*Why:* users can see what changed and whether they need to act. *Verified by:* the
release workflow. *Maps to:* OSPS-BR-04.01.

**K22-REL-03 (MUST)** Every release asset's file name contains the version (or the asset
is a fixed-name channel file listed with its hash in the release's `SHA256SUMS`).
*Why:* an asset found in the wild can be traced to its release. *Verified by:* release
workflow. *Maps to:* OSPS-BR-02.02.

## Integrity and provenance

**K22-REL-04 (MUST)** Every release asset is listed in a `SHA256SUMS` file published
with the release, and has a GitHub artifact attestation (Sigstore-signed SLSA build
provenance) created by the shared reusable release workflow.
*Why:* anyone can verify that an asset is unmodified and was built by the KofTwentyTwo
pipeline from a specific commit. This meets SLSA Build Level 3. *Verified by:*
`gh attestation verify`. *Maps to:* OSPS-BR-06.01, SLSA Build L3.

**K22-REL-05 (MUST)** Platform code signing is applied where the platform expects it:

| Artifact | Signing |
| --- | --- |
| Windows executables, DLLs, installers, MSIX | Authenticode, through Azure Trusted Signing with a timestamp |
| macOS applications and installers | Developer ID signature, notarized and stapled |
| NuGet packages | Published through nuget.org trusted publishing (repository-signed by nuget.org) |
| Container images | Keyless Sigstore signature plus attestation |

*Why:* the operating system and package manager can verify the publisher before
anything runs. *Verified by:* release workflow; `Get-AuthenticodeSignature`,
`codesign --verify`, `spctl`. See exception [EX-0002](../exceptions/register.md#ex-0002)
for Windows signing during identity validation.

**K22-REL-06 (MUST)** Every release that ships compiled software includes a
[CycloneDX](https://cyclonedx.org/) 1.6 SBOM (JSON) for each shipped artifact, generated
in the release workflow from the resolved dependency graph, attached to the release and
attested.
*Why:* consumers can check what they are running against new advisories.
*Verified by:* release assets; `gh attestation verify --predicate-type
https://cyclonedx.org/bom`. *Maps to:* OSPS-QA-02.02.

**K22-REL-07 (MUST)** Releases are immutable. The workflow creates a draft, uploads every
asset and the notes, then publishes; published assets are never replaced. A broken
release is fixed by a new version, and the broken release's notes say so.
*Why:* a published release must mean the same bytes for everyone, forever.
*Verified by:* repository immutable-releases setting
([`K22-REPO-30`](repository.md#security-settings)).

## Distribution

**K22-REL-10 (MUST)** Official download and update channels (GitHub Releases, package
registries, update feeds, winget, Homebrew taps) are listed in the README, and every one
of them is served over HTTPS with authenticated transport.
*Why:* users must know which sources are genuine, and downloads must not be
interceptable. *Verified by:* review. *Maps to:* OSPS-BR-03.01, OSPS-BR-03.02.

**K22-REL-11 (MUST)** Publishing to registries uses trusted publishing (OIDC) where the
registry supports it; otherwise a token scoped to the project's packages, stored in the
protected `release` environment.
*Why:* no long-lived publishing credential to steal. *Verified by:*
[`K22-CI-16`](ci-cd.md#workflow-security).

## Release process

**K22-REL-12 (MUST)** Each MINOR or MAJOR release has a release checklist (an issue made
from [`templates/release-checklist.md`](../templates/release-checklist.md)) completed
before tagging. It records: the conformance check result (`K22-SDLC-33`), the security
assessment (`K22-SEC-30`), the threat model review (`K22-SDLC-03`), open security
findings and their VEX statements (`K22-SEC-42`), and any mutation or fuzz testing
(`K22-TEST-11`, `K22-TEST-23`). PATCH releases need only the conformance check and scan
results.
*Why:* the decisions behind a release are written down where the next release can
see them. *Verified by:* the checklist issue linked from the release notes. *Maps to:*
OSPS-SA-03.01.

## Support and verification

**K22-REL-20 (MUST)** Each Product's `SECURITY.md` states which versions receive fixes
and for how long. The default policy is:

- the latest MINOR of the latest MAJOR receives all fixes;
- when a new MAJOR is released, the previous MAJOR's last MINOR receives security fixes
  for 6 months;
- everything else is unsupported, and the `SECURITY.md` says so.

*Why:* users need to know whether staying on their version is safe. *Verified by:*
conformance checker (`SECURITY.md` sections). *Maps to:* OSPS-DO-04.01, OSPS-DO-05.01.

**K22-REL-21 (MUST)** Each Product's README links to verification instructions that let a
user confirm both the integrity and the origin of a download:

### Verifying a release

```powershell
# 1. Integrity: the file matches the published checksum
sha256sum --check --ignore-missing SHA256SUMS            # Linux / macOS
(Get-FileHash .\MyApp-1.2.3-Setup.exe -Algorithm SHA256).Hash   # Windows; compare to SHA256SUMS

# 2. Origin: built by KofTwentyTwo's release workflow from this repository
gh attestation verify .\MyApp-1.2.3-Setup.exe --repo KofTwentyTwo/MyApp `
  --signer-repo KofTwentyTwo/standards

# 3. Publisher (Windows): Authenticode signature
Get-AuthenticodeSignature .\MyApp-1.2.3-Setup.exe | Format-List Status, SignerCertificate
```

*Why:* a checksum alone proves only that the file matches what was published; the
attestation proves who built it and how. *Verified by:* conformance checker (README
link). *Maps to:* OSPS-DO-03.01, OSPS-DO-03.02.
