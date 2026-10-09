# KofTwentyTwo standards

Public policies, coding standards (Kingsrook style), reference architectures, and the
configs and reusable workflows that enforce them. Original KofTwentyTwo content: never
copy text from employer or client documents into this repository.

## Conventions (see policies/README.md)

- Requirements: `**K22-<AREA>-<NN> (MUST|SHOULD|MAY)** rule` then `*Why:* … *Verified by:* … *Maps to:* …`.
  IDs are never reused or renumbered; retire instead.
- Every requirement needs a "Verified by". If you add a MUST, add or extend its check in
  `tools/Test-RepoConformance.ps1` or the reusable workflows, and update
  `compliance/osps-baseline.md` if it maps to a framework control.
- A new MUST that existing repos don't meet is a MAJOR release of this repo.
- Actions pinned by full SHA with `# vX.Y.Z` comment; images by digest.
- LF line endings everywhere (`.gitattributes`).

## Checks

```powershell
zizmor .github/workflows                 # workflow security
actionlint                               # workflow syntax
gitleaks detect --source . --no-banner   # secrets
pwsh tools/Test-RepoConformance.ps1 -Repository KofTwentyTwo/standards -LocalPath .
```

## Workflow

GitHub Flow: topic branch `<type>/<desc>` → PR to `main` → squash merge. Conventional
Commit titles, `git commit -s` (DCO), signed commits. Agents never merge, tag, release,
or change repository settings (policies/ai-assisted-development.md).
