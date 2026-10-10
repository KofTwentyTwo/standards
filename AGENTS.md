# Repository Guidelines

## Project Structure & Module Organization

This repository publishes KofTwentyTwo engineering standards and enforcement tooling.
`policies/` defines requirements; `standards/` provides implementation and language
profiles; `architecture/` contains reference designs. `configs/` holds IDE, formatter,
linter, and scanner settings. `templates/` contains starter repository files and
workflow callers; `.github/workflows/` contains reusable workflows and repository CI.
PowerShell tooling lives in `tools/`, workstation setup in `setup/`, framework
crosswalks in `compliance/`, and approved deviations in `exceptions/`.

## Build, Test, and Development Commands

There is no application build or local server. Run these checks from the repository
root with the corresponding tools installed:

```powershell
npx markdownlint-cli2 "**/*.md"
lychee --offline --include-fragments --no-progress './**/*.md'
pwsh tools/Test-RepoConformance.ps1 -SelfTest
pwsh tools/Test-RepoConformance.ps1 -LocalPath . -StaticOnly
zizmor .github/workflows
actionlint
gitleaks detect --source . --no-banner
```

These check Markdown, internal links and anchors, checker behavior, local conformance,
workflow security, workflow syntax, and secrets respectively. For GitHub settings,
run the checker with `-Repository KofTwentyTwo/standards -LocalPath .`; this requires
authenticated GitHub access and sufficient permissions.

## Coding Style & Naming Conventions

Follow `.editorconfig`: UTF-8, LF, final newline, three-space indentation by default,
and two spaces for YAML. Follow language profiles in `standards/coding/` and their
matching `configs/`; PowerShell uses approved verbs and Allman braces. Markdown
follows `.markdownlint-cli2.yaml`, which disables line-length limits. Use descriptive
kebab-case document names, such as `security-program.md`.

Write requirements as `K22-<AREA>-<NN>` with MUST, SHOULD, or MAY, followed by
*Why* and *Verified by*. Never reuse or renumber IDs. Extend enforcement for new MUSTs
and update applicable compliance crosswalks in the same change.

## Testing Guidelines

Checker regression tests are built into `-SelfTest`; there is no separate test
directory or repository-wide coverage gate. Extend those tests when changing checker
behavior. Validate documentation with Markdown and internal-link checks; validate
workflow changes with actionlint and zizmor. All required CI checks must pass.

## Commit & Pull Request Guidelines

History uses Conventional Commits, such as `feat(ci): ...` and `fix(docs): ...`.
Use topic branches like `docs/clarify-dco`; target `main`. Sign commits and add DCO
sign-off with `git commit -s`. PR titles must also be Conventional Commits. Describe
the change and validation, link relevant issues, and resolve review threads before
squash merging. Discuss requirement changes in an issue first; label incompatible
new MUSTs `breaking`.

## Security & Agent Instructions

Keep content original; never copy employer or client documents. Pin external Actions
to full commit SHAs with version comments and images to digests. Follow `SECURITY.md`
for private reports and `policies/ai-assisted-development.md` for agent permissions.
