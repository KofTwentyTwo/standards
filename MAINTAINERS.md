# Maintainers and repositories

Who has access to KofTwentyTwo's sensitive resources (repository administration,
release publishing, package namespaces, signing identities), and which repositories
make up KofTwentyTwo software. Changes to this file go through a pull request
([GOVERNANCE.md](GOVERNANCE.md)).

## People

| Name | GitHub | Role | Access | Since |
| --- | --- | --- | --- | --- |
| James Maes | [@KofTwentyTwo](https://github.com/KofTwentyTwo) | Maintainer, security contact | Admin on all repositories; owner of package namespaces and signing identities | 2026 |

Security reports go through each repository's private vulnerability reporting
([SECURITY.md](SECURITY.md)), not to personal channels.

## Repositories

The Product-tier repositories: public, publishing releases, and held to every standard
([`K22-REPO-42`](standards/repository.md#repository-hygiene)). Each states its
conformance version in its README.

| Repository | What it is | Tier | Conformance |
| --- | --- | --- | --- |
| [standards](https://github.com/KofTwentyTwo/standards) | These policies, standards, configs, and reusable workflows | Product | v1.0 (this release) |
| [AppKit](https://github.com/KofTwentyTwo/AppKit) | Shared foundation packages for Windows desktop apps | Product | Adoption in progress |
| [gclo](https://github.com/KofTwentyTwo/gclo) | Clone and update every repository of a GitHub organization (Windows app and CLI) | Product | Adoption in progress |

### Awaiting classification

These public repositories publish releases and will be classified as Product (and
brought into conformance) or moved to Internal in a later pull request:
CommandTabFree, intellij-commentator-plugin, Jarvis, license-tool, limen,
Lukes-Rocket-Launcher, Munitor, notion-sql, obsidian-penny.

Every other repository is Internal tier until it is listed above
([scope](policies/README.md#scope)).
