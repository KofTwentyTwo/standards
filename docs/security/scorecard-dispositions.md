# Scorecard finding dispositions

Reviewed on 2026-10-10 for the v0.1.0 release. These are repository-process
heuristics, not identified vulnerabilities in shipped code or dependencies.
Static review inspected the reported main revision, current rulesets, the security
policy, and EX-0001. It does not establish an independent human review of historical
changes or predict future maintenance.

| Alert | Disposition and evidence | Reassess |
| --- | --- | --- |
| [#4 Code-Review](https://github.com/KofTwentyTwo/standards/security/code-scanning/4) | Accepted single-maintainer risk under [EX-0001](../../exceptions/register.md#ex-0001). Outside contributors cannot merge; PR checks, AI review, CodeQL, signed commits, and maintainer merge remain required. Scorecard counts human approvals, so it does not represent these compensating controls. | 2027-01-10, or when a second maintainer joins |
| [#3 Maintained](https://github.com/KofTwentyTwo/standards/security/code-scanning/3) | Age heuristic: GitHub reports creation on 2026-10-09, with recent feature PRs and active CI. The message identifies a repository younger than 90 days, rather than abandoned shipped software. | 2027-01-10 |
| [#1 Branch-Protection](https://github.com/KofTwentyTwo/standards/security/code-scanning/1) | Accepted human-approval gap under EX-0001. Active `protect-main` has no bypass and enforces PR-only squash merges, nine required checks, signed commits, linear history, and resolved threads. Human approval by another maintainer is unavailable. | 2027-01-10, or when a second maintainer joins |

Keep the accepted risk visible; dismissal is not a claim that the missing second
maintainer exists. Do not disable Scorecard or weaken protections. Reopen and
reassess these dispositions when their assumptions change. The LOW best-practices
badge and MEDIUM fuzzing recommendations remain open for follow-up.

No OpenVEX statement is fabricated for these process findings: no vulnerable shipped
component or exploit was identified. Any actual vulnerability present but not
exploitable needs the OpenVEX statement required by K22-SEC-42.
