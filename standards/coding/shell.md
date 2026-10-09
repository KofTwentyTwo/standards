# Shell and PowerShell profile

The [Kingsrook coding standard](README.md) applied to Bash and PowerShell scripts.
Requirement IDs are `K22-CODE-SH-NN`. Configuration:
[`configs/shell/`](../../configs/shell).

## Tooling

| Concern | Bash | PowerShell |
| --- | --- | --- |
| Version | Bash 5 (`#!/usr/bin/env bash`) | PowerShell 7.4+ (`#Requires -Version 7.4`) |
| Formatter | [shfmt](https://github.com/mvdan/sh) (reads `.editorconfig`) | `Invoke-Formatter` (PSScriptAnalyzer) |
| Linter | [ShellCheck](https://www.shellcheck.net) with [`.shellcheckrc`](../../configs/shell/.shellcheckrc) | PSScriptAnalyzer with [`PSScriptAnalyzerSettings.psd1`](../../configs/shell/PSScriptAnalyzerSettings.psd1) |
| Tests | [bats-core](https://github.com/bats-core/bats-core) for non-trivial scripts | Pester 5 |

## Requirements

**K22-CODE-SH-01 (MUST)** Bash scripts start with `#!/usr/bin/env bash` and
`set -euo pipefail`, quote every expansion, and pass `shellcheck` with all optional
checks enabled.
*Verified by:* ShellCheck in CI.

**K22-CODE-SH-02 (MUST)** Bash layout is shfmt with the KofTwentyTwo `.editorconfig`
keys: **3-space indentation**, binary operators leading continuation lines, function
braces on the next line (`function_next_line`). Deviation: `if`/`for`/`while` bodies are
delimited by `then`/`do`, not braces, and `[[`/`(` need their surrounding spaces, so
K22-CODE-04 and K22-CODE-05 apply only to function bodies.
*Verified by:* `shfmt --diff` in CI.

**K22-CODE-SH-03 (MUST)** A script that grows past roughly 100 lines, or needs data
structures beyond arrays, is rewritten in the repository's main language (or PowerShell /
Python for tooling).
*Verified by:* review.

**K22-CODE-SH-04 (MUST)** PowerShell scripts use `Set-StrictMode -Version Latest` and
`$ErrorActionPreference = 'Stop'`, approved verbs, full cmdlet names (no aliases), and
`[CmdletBinding()]` parameters with validation attributes.
*Verified by:* PSScriptAnalyzer.

**K22-CODE-SH-05 (MUST)** PowerShell layout is the full Kingsrook layout, which
PSScriptAnalyzer can enforce: next-line (Allman) braces, 3-space indentation, consistent
whitespace, and comment-based help on every function (the PowerShell form of the header
comment, K22-CODE-09).
*Verified by:* `Invoke-ScriptAnalyzer -Settings PSScriptAnalyzerSettings.psd1 -EnableExit`.

**K22-CODE-SH-06 (MUST)** Scripts never echo secrets, never pass them on a command line
(they appear in process listings), and read them from the environment or a secret store.
*Verified by:* gitleaks; review. *Maps to:* OSPS-BR-07.02.

## Commands

| Where | Command |
| --- | --- |
| Local fix (Bash) | `shfmt --write .` |
| Local fix (PowerShell) | `Invoke-Formatter` per file, or the VS Code PowerShell extension with the settings file |
| CI | `shellcheck $(git ls-files '*.sh')`, `shfmt --diff .`, `Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1 -EnableExit` |
