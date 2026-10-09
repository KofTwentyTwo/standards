# Release checklist: vX.Y.Z

<!-- K22-REL-12. Open as an issue titled "Release vX.Y.Z" before tagging. PATCH
     releases complete sections 1, 2, and 5 only. Link this issue from the release
     notes. -->

## 1. Conformance (K22-SDLC-33)

- [ ] `tools/Test-RepoConformance.ps1 -Repository KofTwentyTwo/{{repo}}` has no FAIL
      (EXCEPTED is fine). Output attached below.
- [ ] Exceptions this repository relies on are open and unexpired.

## 2. Scans and findings (K22-SEC-41, K22-SEC-42)

- [ ] No open code-scanning alerts at HIGH or CRITICAL on `main`.
- [ ] No open Dependabot alerts at HIGH or CRITICAL for shipped dependencies.
- [ ] Every known-but-not-exploitable finding has an OpenVEX statement in
      `docs/security/vex.json` with a justification.

## 3. Security assessment (K22-SEC-30, K22-SDLC-03)

- [ ] Threat model reviewed against the changes since the previous release; review log
      updated.
- [ ] New or changed external interfaces: {{list or "none"}}.
- [ ] Most likely and most impactful problems for this release, and how they are
      addressed: {{notes}}.

## 4. Test depth (K22-TEST-11, K22-TEST-23)

- [ ] Mutation testing run on core logic (libraries): {{score / notes / n-a}}.
- [ ] Fuzz targets run for parsers of untrusted input: {{notes / n-a}}.

## 5. Ship

- [ ] `main` is green; release notes reviewed (breaking changes and security fixes
      first).
- [ ] Tag `vX.Y.Z` pushed; release workflow green.
- [ ] Release assets verified: `SHA256SUMS`, attestations (`gh attestation verify`),
      SBOM present, platform signature valid.
- [ ] Announcements and channel updates done (winget, Homebrew, registries).

<details><summary>Conformance output</summary>

```text
paste here
```

</details>
