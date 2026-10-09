# .NET

Drop-in files that implement the [C# / .NET profile](../../standards/coding/csharp-dotnet.md):
the Kingsrook layout plus the shared quality and supply-chain rules. With them in place,
`dotnet build` fails locally on exactly the same problems that fail CI.

| File | Copy to | Purpose |
| --- | --- | --- |
| [`.editorconfig`](.editorconfig) | repository root | Kingsrook layout (3-space indent, Allman braces, `if(`), naming, code-style rules at build-failing severity, Rider/ReSharper blank-line keys, justified analyzer adjustments |
| [`Directory.Build.props`](Directory.Build.props) | repository root | Warnings as errors, analyzers, style in build, nullable, deterministic builds, NuGet audit (all) and lock files, Meziantou.Analyzer |
| [`Directory.Packages.props.example`](Directory.Packages.props.example) | repository root as `Directory.Packages.props` | Central package versions, including the pinned analyzer |

A polyglot repository uses [`../editorconfig/.editorconfig`](../editorconfig) instead,
whose `[*.cs]` sections are identical to this file's.

No Rider/ReSharper `.DotSettings` layer is needed: Rider and ReSharper read the
`resharper_*` keys in `.editorconfig`, which carry the one Kingsrook rule the .NET
formatter cannot express (three blank lines between members).

## Adopting in an existing repository

1. Copy the three files. Keep any repository-specific groups of an existing
   `Directory.Build.props` (version, package metadata) and replace its quality settings.
2. Set `* text=auto eol=lf` in `.gitattributes` (K22-CODE-07).
3. Restore once so `packages.lock.json` files are created, and commit them.
4. Reformat and fix:

   ```powershell
   dotnet format                                   # layout, var, usings, naming, line endings
   dotnet build -warnaserror                       # remaining analyzer findings
   ```

5. Commit the reformat on its own (`style: adopt Kingsrook layout`) so `git blame` can
   skip it: add that commit's hash to `.git-blame-ignore-revs`.

## IDEs

- **Visual Studio 2026:** reads `.editorconfig` natively, including the formatting and
  naming rules; *Code Cleanup* applies them. Keep *Tools → Options → Text Editor → C# →
  Code Style → General → "Analyze code style during build"* on (it is the build's
  setting anyway).
- **Rider / ReSharper:** reads `.editorconfig` (including the `resharper_*` keys).
  *Settings → Editor → Code Style* shows the values as "from EditorConfig". Run *Code →
  Reformat and Cleanup* or enable cleanup on save.
- **VS Code (C# Dev Kit):** reads `.editorconfig`; see [`../vscode`](../vscode).

## Command line

| Purpose | Command |
| --- | --- |
| Build with every rule | `dotnet build -warnaserror` |
| Fix layout and style | `dotnet format` |
| CI gate | `dotnet format <solution> --verify-no-changes --severity warn --no-restore` |
| Locked restore (automatic in CI) | `dotnet restore --locked-mode` |

## What is deliberately relaxed

| Rule | Where | Why |
| --- | --- | --- |
| `CA1716` | everywhere | Flags member names that are VB keywords (`Error`); KofTwentyTwo code is C#-only |
| `MA0004` (`ConfigureAwait`) | everywhere | App code resumes on UI threads; libraries opt in (K22-CODE-CS-13) |
| `MA0049` | everywhere | Conflicts with the `App` / `App.Core` project layout |
| `CA1707`, `CA1861`, `CS1591`, `MA0048` | `tests/`, `test/` | xUnit naming, inline test data, undocumented tests, one file per feature's tests |
| `CS1591` | non-packable projects | Only shipped libraries must document their public API |

## Verified

On .NET SDK 10.0.401 with Meziantou.Analyzer 3.0.296: a Kingsrook-style class library
and console app build with 0 warnings and pass `dotnet format --verify-no-changes`, and
the build fails on each of: an unused `using` (IDE0005), 4-space indentation, a
same-line (K&R) brace, `foreach (` with a space (all IDE0055), and a Meziantou rule
(MA0006, MA0011). Locked restore rejects a version that differs from the lock file
(NU1004).
