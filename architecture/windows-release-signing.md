# Windows release signing

The reusable NuGet and Velopack builders support Azure Artifact Signing over GitHub
OIDC. Reuse an existing validated signing account and active PublicTrust profile;
retrieve the actual tenant GUID, regional account URI, profile name and certificate
subject from Azure before setting variables. Account/domain names and subscription
IDs are not tenant GUIDs. Do not export a private key or use an administrator's
password in CI.

## Trust and configuration

Configure a reviewed Entra application/service principal per repository, or reuse a
suitable existing CI identity while preserving other repositories' credentials.
Use the issuer `https://token.actions.githubusercontent.com`, audience
`api://AzureADTokenExchange` and subject `repo:OWNER/REPOSITORY:environment:release`.
Protect the `release` environment against untrusted refs. Assign the built-in
**Artifact Signing Certificate Profile Signer** at the existing certificate profile
scope; Azure Owner/Contributor is not a signing permission.

Set these environment variables using verified deployed values:

| Variable | Value |
| --- | --- |
| `AZURE_TENANT_ID` | Actual tenant GUID |
| `AZURE_CLIENT_ID` | CI application client ID |
| `AZURE_SUBSCRIPTION_ID` | Signing subscription ID |
| `ARTIFACT_SIGNING_ENDPOINT` | Account's regional HTTPS URI |
| `ARTIFACT_SIGNING_ACCOUNT` | Existing account resource name |
| `ARTIFACT_SIGNING_PROFILE` | Existing active profile name |
| `ARTIFACT_SIGNING_SUBJECT` | Profile certificate's verified subject |

Callers can retain legacy `TRUSTED_SIGNING_ENDPOINT`, `_ACCOUNT`, `_PROFILE` and
`_SUBJECT` names; the new names take precedence. The verified subject is required.
Both builders use official full-SHA-pinned `azure/login` v3 and
`azure/artifact-signing-action` v2, Windows runners and `AzureCliCredential` only.
Signing jobs run in `release` with `contents: read` and `id-token: write`. No
pull-request signing path exists. SHA256 file digests and RFC3161 SHA256 timestamps
at `http://timestamp.acs.microsoft.com` are mandatory when signing is enabled.

## Caller inputs and artifact order

Set `sign: true` and a newline-separated `signing-files` list. Every pattern must
match; missing binaries fail rather than quietly omitting a signature.
Owned and preserved `.exe`/`.dll` headers must parse before a catalog is written;
hash preservation cannot prove an already corrupt source is executable. MSI/MSIX
use their package/signature validation paths rather than PE parsing. For NuGet,
use exact checkout-relative built DLL paths. For Velopack, use publish-relative
paths such as `app/MyApp.exe`, `app/MyApp.dll`, `app/MyApp.Core.dll` and
`cli/myapp.exe`. Include all owned modules. Exclude third-party dependencies.

NuGet signs before `pack --no-build`, then checks the DLLs inside the final packages
against their signed originals. Velopack signs owned published binaries, preserves
other binary hashes, and uses vpk's signing hook only for its branded Squirrel and
execution stubs plus the final Setup/MSI. Final checks validate trust, expected
publisher, timestamps and SHA256 for the shipped binaries, require unchanged
dependency bytes, and verify Setup's embedded full package matches the verified
full update package. Culture-directory satellite assemblies retain their separate
paths. Verification precedes upload, SBOM attestations, checksums and provenance.

Signing or verification failure stops publication when `sign` is true. The default
remains false for compatibility; each owner must enable required signing in their
caller or block publication during migration. NuGet/ZIP/delta containers are not
Authenticode targets. Test reconstructed delta updates on installed channel builds
before claiming upgrade coverage. MSIX presets must use the verified subject as
their manifest Publisher.

## Local tools and proof

Use Microsoft's [current integration instructions](https://learn.microsoft.com/azure/artifact-signing/how-to-signing-integrations)
for Artifact Signing Client Tools, matching-architecture SignTool and
`Azure.CodeSigning.Dlib.dll`, .NET 8 and the Visual C++ runtime. Metadata fields are
`Endpoint`, `CodeSigningAccountName` and `CertificateProfileName`. Authenticate with
an identity that has the profile signer role and sign with `/fd SHA256`,
`/tr http://timestamp.acs.microsoft.com`, `/td SHA256`, `/dlib` and `/dmdf`.

Run `signtool verify /pa /all /v` on final installers and extracted shipped binaries.
Record publisher, trust, timestamp, exact artifact hashes and the CI run. An active
profile, a mocked test or a signed Microsoft tool does not prove an application's
signing works. Retain any signing exception until real end-to-end evidence exists.

## Prepared rollout

This implementation is prepared against published standards v1.0.0. Preserve that
release's metadata, policy changes and signing evidence. Its released Velopack
path lacks the explicit owned-file catalog and its NuGet path lacks these signing
inputs, so it is not sufficient for an AppKit caller that requires them.

The prepared workflows reference helper snapshot `4a7f028976163cb80730126eda1b029005803325`,
which includes source PE parsing and final missing-dependency checks. These references remain
unreleased placeholders until the reviewed helper commit is available on GitHub
and the completed builder is published with its proper version comment. Verify
that exact helper revision, not an older catalog implementation. Keep consumer
publication blocked until the reviewed builder is published, pinned and proven
with representative signed artifacts. Local tests do not authorize rollout.
