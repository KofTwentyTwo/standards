# VS Code

| File | Copy to | Purpose |
| --- | --- | --- |
| [`settings.json`](settings.json) | `.vscode/settings.json` | 3-space indentation, LF, format on save, and the right formatter and linter configuration for every KofTwentyTwo language |
| [`extensions.json`](extensions.json) | `.vscode/extensions.json` | Recommended extensions (VS Code prompts to install them), and Prettier marked unwanted |

Delete the language sections the repository does not use. Layout itself comes from the
repository's `.editorconfig` (the EditorConfig extension is recommended), and each
language's formatter reads its own config file from [`configs/`](..):

| Language | Formatter on save | Reads |
| --- | --- | --- |
| C# | C# Dev Kit | `.editorconfig` |
| Java | Language Support for Java (Red Hat) | Kingsrook Eclipse profile (URL) + Checkstyle (URL) |
| TypeScript / JavaScript | ESLint (flat config, `@stylistic`) | `eslint.config.mjs` |
| Python | Ruff | `ruff.toml`; Pylance strict |
| Rust | rust-analyzer | `rustfmt.toml`; clippy on save |
| Go | Go | gofmt (tabs) |
| Swift | Swift | `.swift-format` |
| Shell | shfmt | `.editorconfig` shfmt keys; ShellCheck |
| PowerShell | PowerShell (Allman preset) | `PSScriptAnalyzerSettings.psd1` |
| Terraform | HashiCorp Terraform | `fmt` |

The files are JSON with comments (JSONC), which VS Code accepts in `.vscode/`.
