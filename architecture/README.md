# Reference architectures

Worked designs for each kind of product KofTwentyTwo builds. Each one already meets
the policies and standards, so a project that follows it starts compliant. A project
that departs from its reference architecture records why in an ADR
([`K22-SDLC-02`](../policies/sdlc.md#plan-and-design)).

| Architecture | Status | Implemented by |
| --- | --- | --- |
| [Windows desktop application](windows-desktop-app.md) | Active | [AppKit](https://github.com/KofTwentyTwo/AppKit), the Windows app template, [gclo](https://github.com/KofTwentyTwo/gclo) |
| macOS application (Swift / SwiftUI) | Planned | |
| Command-line tool (Rust or Go) | Planned | |
| Web application and API | Planned | |
| Kubernetes workload and GitOps delivery | Planned | |

Every reference architecture covers the same sections, so they can be compared:
stack, repository layout, runtime and startup, data and secrets, updates or
deployment, the build and release pipeline, a threat model summary, and the testing
strategy.

Templates used by product repositories: [ADR](../templates/adr.md),
[threat model](../templates/threat-model.md),
[release checklist](../templates/release-checklist.md).
