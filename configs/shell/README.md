# Shell and PowerShell

Implements the [Shell and PowerShell profile](../../standards/coding/shell.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`.shellcheckrc`](.shellcheckrc) | repository root | ShellCheck with every optional check enabled |
| [`editorconfig-shfmt.ini`](editorconfig-shfmt.ini) | merge into `.editorconfig` | shfmt layout: 3-space indent, next-line function braces, leading binary operators |
| [`PSScriptAnalyzerSettings.psd1`](PSScriptAnalyzerSettings.psd1) | repository root | PSScriptAnalyzer and `Invoke-Formatter`: Allman braces, 3-space indent, no aliases, no `Write-Host`, comment-based help |

## Bash

```bash
shellcheck $(git ls-files '*.sh')
shfmt --diff .          # CI
shfmt --write .         # fix
```

## PowerShell

```powershell
Install-Module PSScriptAnalyzer -Scope CurrentUser
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1 -EnableExit
Invoke-Formatter -ScriptDefinition (Get-Content script.ps1 -Raw) -Settings ./PSScriptAnalyzerSettings.psd1
```

## IDEs

- **VS Code:** ShellCheck and shfmt extensions; the PowerShell extension with
  `powershell.codeFormatting.preset: Allman` and `powershell.scriptAnalysis.settingsPath`
  (see [`../vscode`](../vscode)).
- **JetBrains:** the Kingsrook IntelliJ scheme already sets Shell Script to 3-space
  indentation; install the *Shell Script* plugin's shellcheck integration.

## Verified

PSScriptAnalyzer 1.25.0: a Kingsrook-style function passes with no findings; a same-line
brace, 4-space indentation, `Write-Host`, and missing help are each reported, and
`Invoke-Formatter` rewrites the bad script to next-line braces and 3-space indentation.
ShellCheck and shfmt settings follow their documented keys and were not run here.
