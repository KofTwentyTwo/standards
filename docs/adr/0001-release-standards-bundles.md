# ADR-0001: Release standards as immutable GitHub bundles

- **Status:** Accepted with the reviewed implementation PR
- **Date:** 2026-10-10
- **Decider:** Repository maintainer

## Context

Consumers need a versioned package of the policies, standards, configs, templates,
and tooling. Content spans several languages and two primary licenses; it has no
application runtime or build. Existing policies require Conventional Commits,
maintainer-created protected tags, gated reusable release workflows, checksums,
attestations, and immutable GitHub Releases.

## Options considered

- **GitHub ZIP/tar.gz bundle:** preserves the full repository layout and works for
  every consumer with no package-manager dependency. Extraction and copying configs
  remain explicit consumer actions.
- **npm or NuGet package:** convenient for one ecosystem, but imposes that ecosystem
  on documentation and polyglot tooling. Adds a registry and publishing policy.
- **Automatic tags on every merge:** fewer maintainer steps, but conflicts with the
  current tag-creation ruleset and release-checklist process.

## Decision

Use Release Please for version/changelog PRs and publish ZIP/tar.gz bundles through
the reusable `release-standards.yml` workflow when the maintainer tags the merged
release PR. Build from the Git commit, attest all assets, upload everything to a
draft, and publish only with repository immutability enabled.

## Consequences

- Consumers can pin, verify, and extract a standards snapshot across platforms.
- Hidden configuration and license notices remain part of the package.
- Version proposals pass normal review; maintainers retain tag creation and release
  approval. No ruleset bypass or registry publishing secret is added.
- A scoped GitHub App is needed for release PR CI and the settings-read check. Its
  key is held in environment secrets; installation tokens are scoped per job and
  revoked. Main-only access for the version bot is covered by
  [EX-0006](../../exceptions/register.md#ex-0006); publishing remains tag-only.
- Packaging excludes local edits and untracked files. Rebuilds require the same
  source commit, version, checklist URL, and compatible Git tooling.
- Complete App/environment setup and the first-release checklist before activating
  the pipeline. This ADR is reviewed with the implementation PR.
- Review the [distribution threat model](../security/threat-model.md), including the
  version-bot credential boundary and its scoped exception, in the same PR.
