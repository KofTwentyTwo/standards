# Governance

KofTwentyTwo is an individual open-source maintainer's account. This document says who
decides what, and how that changes as the project grows.

## Model

KofTwentyTwo projects are run by a **single maintainer** who has final responsibility
for every repository, release, and security decision. Decisions are made in public:
in issues and pull requests, and for significant ones in architecture decision records
([`K22-SDLC-02`](policies/sdlc.md#plan-and-design)).

## Roles and responsibilities

| Role | Responsibilities | Access |
| --- | --- | --- |
| **Maintainer** | Sets direction; reviews and merges changes; cuts releases; responds to security reports; owns the security program; keeps these standards current | Admin on every repository, owner of package namespaces and signing identities |
| **Collaborator** | Contributes regularly to a specific repository; may triage issues and review pull requests | Triage or write on named repositories only, granted under [`K22-SEC-02`](policies/security-program.md#accounts-and-access) |
| **Contributor** | Opens issues and pull requests | None beyond public access |
| **Automation** | CI, Dependabot, AI coding agents acting through pull requests | Least-privilege tokens; never merges or releases ([`K22-AI-10`](policies/ai-assisted-development.md#agent-permissions)) |

Current holders of each role with access to sensitive resources are listed in
[MAINTAINERS.md](MAINTAINERS.md).

## Adding a maintainer or collaborator

1. The person has a track record of accepted contributions in the repositories concerned.
2. The maintainer opens a pull request adding them to [MAINTAINERS.md](MAINTAINERS.md)
   with the role and repositories, and confirms their account uses phishing-resistant
   MFA ([`K22-SEC-01`](policies/security-program.md#accounts-and-access)).
3. Access is granted after the pull request merges, at the lowest level that fits.
4. When the project has two maintainers, every `protect-main` ruleset moves to one
   required approval and exception [EX-0001](exceptions/register.md#ex-0001) is closed.

## Removing access

Access is removed when it is no longer used (at the latest at the annual access review,
[`K22-SEC-04`](policies/security-program.md#accounts-and-access)), on request, or
immediately if an account may be compromised. The change is recorded in
[MAINTAINERS.md](MAINTAINERS.md).

## Changing these standards

Changes to this repository go through pull requests like any other change. Changes that
add a **MUST** or remove an allowance are released as a new MAJOR version with notes on
what repositories need to do.
