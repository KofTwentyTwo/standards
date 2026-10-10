# Contributing

Proposals, corrections, and new language profiles are welcome. These standards follow
themselves: everything below comes from the [SDLC policy](policies/sdlc.md).

## Before you start

- For a new requirement or a change to an existing one, open an issue first so the idea
  can be discussed in public before anyone writes it up.
- Typos, broken links, and clarifications can go straight to a pull request.

## Making a change

1. Fork the repository and create a topic branch: `<type>/<short-description>`, for
   example `docs/clarify-dco` or `feat/rust-profile`.
2. Commit with a [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/)
   message and a DCO sign-off: `git commit -s -m "docs(sdlc): clarify hotfix path"`.
   The sign-off certifies the [Developer Certificate of Origin](https://developercertificate.org/).
3. Sign your commits (SSH or GPG) so they show as *Verified*.
4. Open a pull request to `main`. The title must also be a Conventional Commit, because
   it becomes the squash commit message.

## What a good change looks like

- A new or changed requirement follows the format in
  [policies/README.md](policies/README.md#requirement-ids): an ID that has never been used,
  a level, the rule, *Why*, and *Verified by*. A requirement nobody can verify is not
  accepted.
- If it maps to a framework control, the crosswalk in [`compliance/`](compliance) is
  updated in the same pull request.
- A new **MUST** that existing repositories do not meet is labeled `breaking` and ships in
  a MAJOR release.
- Configs and workflows pass their own checks: zizmor, actionlint, gitleaks, and the
  conformance checker.

## Running the checks locally

Documentation and package checks:

```powershell
npx markdownlint-cli2 "**/*.md"
lychee --offline --include-fragments --no-progress './**/*.md'
pwsh tools/Test-RepoConformance.ps1 -SelfTest
pwsh tools/Test-RepoConformance.Fuzz.ps1 -Seed 22023 -Iterations 1000
pwsh tools/Test-StandardsPackage.ps1
pwsh tools/Test-RepoConformance.ps1 -LocalPath . -StaticOnly
```

Package tests use an isolated temporary Git fixture; they do not commit changes in
this repository. For version proposals and release bundles, see
[bundle releases](docs/releases.md).

Workflow and security checks:

```powershell
zizmor .github/workflows
actionlint
gitleaks detect --source . --no-banner
pwsh tools/Test-RepoConformance.ps1 -Repository KofTwentyTwo/standards -LocalPath .
```

The same checks run in CI on every pull request and must pass before merging.
Parser changes must pass both CI seeds and retain any discovered failure as a
deterministic regression test. See [fuzzing](docs/security/fuzzing.md) for extended
campaigns and [badge assessment](docs/security/best-practices.md) for enrollment evidence.

## License of contributions

Documentation contributions are licensed under [CC BY 4.0](LICENSE-docs); configuration,
workflows, scripts, and templates under [MIT](LICENSE).
