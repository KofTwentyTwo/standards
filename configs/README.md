# Configs: what your IDE and tools import

Every file an editor, IDE, formatter, linter, or scanner needs to enforce the
[KofTwentyTwo coding standard](../standards/coding/README.md) (Kingsrook style) and the
[security standards](../standards/ci-cd.md#security-scanning). Each folder has a README
with exact import steps for the IDE and the command line.

## By editor or IDE

| You use | Start with | Then add |
| --- | --- | --- |
| **IntelliJ IDEA** and other JetBrains IDEs (WebStorm, PyCharm, GoLand, DataGrip) | [`intellij/`](intellij): Kingsrook code-style scheme, copyright profile, live templates, CheckStyle-IDEA settings | The language folder for your project |
| **Rider** | [`dotnet/`](dotnet) (`.editorconfig` drives Rider's formatter and inspections) | [`intellij/`](intellij) for non-C# files |
| **Visual Studio** | [`dotnet/`](dotnet) | |
| **VS Code** | [`vscode/`](vscode): settings and recommended extensions | The language folder |
| **Eclipse** | [`eclipse/`](eclipse): formatter profile | [`java/`](java) for Checkstyle |
| **Xcode** | [`swift/`](swift) | |
| **Any editor** | [`editorconfig/`](editorconfig): one `.editorconfig` for every language | |

## By language

| Language | Folder | Formatter / linters | Profile |
| --- | --- | --- | --- |
| C# / .NET | [`dotnet/`](dotnet) | `.editorconfig` + analyzers + Meziantou, `dotnet format` | [csharp-dotnet.md](../standards/coding/csharp-dotnet.md) |
| Java | [`java/`](java), [`intellij/`](intellij), [`eclipse/`](eclipse) | IntelliJ scheme, Checkstyle (Maven/Gradle) | [java.md](../standards/coding/java.md) |
| TypeScript / JavaScript | [`typescript/`](typescript) | ESLint flat config with ESLint Stylistic, strict `tsconfig` | [typescript.md](../standards/coding/typescript.md) |
| Python | [`python/`](python) | ruff (lint + format), pyright | [python.md](../standards/coding/python.md) |
| Rust | [`rust/`](rust) | rustfmt, clippy, cargo-deny | [rust.md](../standards/coding/rust.md) |
| Go | [`go/`](go) | gofmt, golangci-lint v2 | [go.md](../standards/coding/go.md) |
| Swift | [`swift/`](swift) | swift-format, SwiftLint | [swift.md](../standards/coding/swift.md) |
| Shell and PowerShell | [`shell/`](shell) | ShellCheck, shfmt, PSScriptAnalyzer | [shell.md](../standards/coding/shell.md) |
| Terraform / OpenTofu | [`terraform/`](terraform) | `fmt`, TFLint | [terraform.md](../standards/coding/terraform.md) |
| SQL | [`sql/`](sql) | sqlfluff | (Java and SQL live templates) |

## Security and hooks (every repository)

| Folder | What |
| --- | --- |
| [`security/`](security) | gitleaks, Trivy, and zizmor configurations, and how to run each locally |
| [`markdown/`](markdown) | markdownlint-cli2 config: all default rules except line length (none, per K22-CODE-08) |
| [`pre-commit/`](pre-commit) | The pre-commit hook set: hygiene, secrets, Conventional Commit messages, DCO sign-off, workflow linting |

Files adopted from Kingsrook's QQQ project keep their original copyright and Apache-2.0
license; see [NOTICE](../NOTICE).
