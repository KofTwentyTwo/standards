# KofTwentyTwo Standards

**How KofTwentyTwo builds, secures, and ships software.** The policies, coding
standards, reference architectures, and the configuration and automation that enforce
them, in one public, versioned repository.

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/KofTwentyTwo/standards/badge)](https://scorecard.dev/viewer/?uri=github.com/KofTwentyTwo/standards)
[![Docs: CC BY 4.0](https://img.shields.io/badge/docs-CC%20BY%204.0-lightgrey)](LICENSE-docs)
[![Code: MIT](https://img.shields.io/badge/code-MIT-green)](LICENSE)

## Start here

| I want to… | Go to |
| --- | --- |
| Understand the rules and how they are written | [How these standards work](policies/README.md) |
| Know the development process | [SDLC policy](policies/sdlc.md) |
| Know the security program | [Security program](policies/security-program.md) |
| Use AI coding agents correctly | [AI-assisted development](policies/ai-assisted-development.md) |
| Set up my IDE or command-line tools | [`configs/`](configs) (one folder per language and tool, each with import steps) |
| Write code in a given language | [Coding standards](standards/coding/README.md) (Kingsrook style) |
| Create or audit a repository | [Repository standard](standards/repository.md) and `tools/Test-RepoConformance.ps1` |
| Wire up CI | [CI/CD standard](standards/ci-cd.md) and the reusable workflows in [`.github/workflows/`](.github/workflows) |
| Ship a release | [Release standard](standards/releases.md) |
| Design a new app | [Reference architectures](architecture/README.md) |
| See where we fall short, and why | [Exception register](exceptions/register.md) |
| Map us to OpenSSF / NIST / SLSA | [Compliance crosswalks](compliance/README.md) |

## What is in here

| Folder | Contents |
| --- | --- |
| [`policies/`](policies) | SDLC, security program, AI-assisted development, exceptions |
| [`standards/`](standards) | Repository, CI/CD, testing, dependencies, releases, coding (per language) |
| [`architecture/`](architecture) | Reference architectures for each kind of product |
| [`configs/`](configs) | Files IDEs and tools import: IntelliJ schemes, Checkstyle, `.editorconfig`, analyzer and linter configs, security scanner and pre-commit configs |
| [`.github/workflows/`](.github/workflows) | Reusable workflows: PR gates, security scanning, CodeQL (and this repository's own CI) |
| [`templates/`](templates) | Starter files for repositories, workflows, ADRs, threat models, release checklists |
| [`tools/`](tools) | `Test-RepoConformance.ps1`: checks a repository against these standards |
| [`compliance/`](compliance) | Crosswalks to OSPS Baseline, NIST SSDF, SLSA, OpenSSF Scorecard |
| [`exceptions/`](exceptions) | The public exception register |

## Adopting the standards in a repository

1. Copy the files in [`templates/repo/`](templates/repo) and the `configs/` for your
   language; replace the `{{placeholders}}`.
2. Add the caller workflows from [`templates/workflows/`](templates/workflows), which
   use the reusable workflows here pinned to a release commit.
3. Apply the rulesets and settings in the [repository standard](standards/repository.md).
4. Run `pwsh tools/Test-RepoConformance.ps1 -Repository KofTwentyTwo/<repo>` and fix
   every FAIL (or record an exception).
5. State the version you conform to in the README: *Conforms to KofTwentyTwo standards
   v1.0*.

## Versioning

This repository follows [Semantic Versioning](https://semver.org); a new **MUST** that
existing repositories do not meet is a MAJOR change. See
[how these standards work](policies/README.md#versioning-of-the-standards). Reusable
workflows are referenced by the commit SHA of a release tag.

## Contributing and security

Proposals and fixes are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md). Report
security issues privately as described in [SECURITY.md](SECURITY.md). Participation is
governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

- Documentation (policies, standards, architecture, compliance): [CC BY 4.0](LICENSE-docs).
- Configuration, workflows, scripts, and templates: [MIT](LICENSE).
- The adopted Kingsrook code-style files are © Kingsrook, LLC under Apache-2.0; see
  [NOTICE](NOTICE).
