# C# / .NET profile

The [Kingsrook coding standard](README.md) applied to C#. Requirement IDs are
`K22-CODE-CS-NN`; every cross-language rule (`K22-CODE-NN`) also applies.
Configuration: [`configs/dotnet/`](../../configs/dotnet).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| SDK and runtime | .NET 10 (LTS) | `global.json` pins the feature band with `rollForward: latestFeature` |
| Formatter | `dotnet format` (built into the SDK) + `.editorconfig` | SDK version |
| Analyzers | .NET analyzers (`AnalysisLevel=latest-recommended`), IDE code-style rules, [Meziantou.Analyzer](https://github.com/meziantou/Meziantou.Analyzer) | Meziantou pinned in `Directory.Packages.props` |
| Blank-line layout (IDE) | Rider / ReSharper via `resharper_*` keys in `.editorconfig` | IDE version |
| Type safety | Nullable reference types (`<Nullable>enable</Nullable>`) | |
| Tests | xUnit, `Microsoft.NET.Test.Sdk` | latest stable, pinned centrally |
| Coverage | coverlet (`XPlat Code Coverage`, Cobertura) | latest stable, pinned centrally |
| UI end-to-end (Windows apps) | FlaUI (UIA3) | latest stable, pinned centrally |
| Security analysis | CodeQL `csharp` (`security-extended`), NuGetAudit | GitHub-managed |
| Dependencies | Central package management + lock files | |

## Requirements

**K22-CODE-CS-01 (MUST)** The repository root holds the standard
[`.editorconfig`](../../configs/dotnet/.editorconfig) and
[`Directory.Build.props`](../../configs/dotnet/Directory.Build.props), so every project
builds with `TreatWarningsAsErrors`, `AnalysisLevel=latest-recommended`,
`EnforceCodeStyleInBuild`, and `GenerateDocumentationFile` (which IDE0005, unused usings,
needs in order to run during build).
*Why:* `dotnet build` then fails locally on exactly what fails in CI. *Verified by:* the
build. *Maps to:* SSDF PW.6.2.

**K22-CODE-CS-02 (MUST)** Kingsrook layout, enforced as `IDE0055` build errors:
3-space indentation, Allman braces (`csharp_new_line_before_open_brace = all`), `else`,
`catch`, and `finally` on new lines, and no space after control keywords
(`if(ready)`, `foreach(var item in items)`).
*Verified by:* `dotnet build` and `dotnet format --verify-no-changes`.

**K22-CODE-CS-03 (MUST)** Members are separated by three blank lines and code blocks
contain at most one consecutive blank line. The .NET formatter cannot count blank lines,
so Rider and ReSharper enforce this from the `resharper_blank_lines_*` keys in
`.editorconfig`, and review checks it in other editors.
*Verified by:* Rider/ReSharper code cleanup; review.

**K22-CODE-CS-04 (MUST)** Header comments (K22-CODE-09) on types and members are XML
documentation comments (`///`), written in Kingsrook's plain "how and why" voice. Inside
method bodies, explanatory comments are `//` flower boxes (K22-CODE-10).

```csharp
/// <summary>
/// Retries a failed upload with backoff, because the update feed rate-limits bursts.
/// </summary>
public async Task<bool> UploadAsync(Package package)
{
   //////////////////////////////////////////////////////////////
   // the feed rejects more than one request per second, so we //
   // wait before the first retry as well as between retries   //
   //////////////////////////////////////////////////////////////
   await Task.Delay(_backoff);
```

*Why this deviates from the Java banner:* C# tooling reads only `///` comments: they
become IntelliSense, NuGet package documentation, and the `CS1591` check that public API
is documented. A `/*****` banner would be invisible to all of that. The three blank lines
between members (K22-CODE-CS-03) provide the banner's visual break.
*Verified by:* `CS1591` for packable projects; review.

**K22-CODE-CS-05 (MUST)** `var` is used only when the type is apparent from the
right-hand side (`var orders = new List<Order>()`); otherwise the type is written out.
Language keywords are used over framework type names (`string`, not `String`), and
members are never qualified with `this.`.
*Verified by:* `IDE0007`, `IDE0008`, `IDE0049`, `IDE0003` as build errors.

**K22-CODE-CS-06 (MUST)** Analyzer findings are fixed, not suppressed. A necessary
suppression uses `[SuppressMessage(..., Justification = "...")]` or `#pragma warning
disable` on the narrowest scope with a reason; a whole-rule relaxation goes in the
repository's `.editorconfig` with a comment explaining why.
*Verified by:* review; `IDE0079` flags unnecessary suppressions.

**K22-CODE-CS-07 (MUST)** Naming: `PascalCase` for types, members, and constants;
interfaces start with `I`, type parameters with `T`; private fields are `_camelCase` and
private static fields `s_camelCase`; one top-level type per file, named after the type
(Meziantou `MA0048`; test files may group a feature's test classes).
*Verified by:* `.editorconfig` naming rules and `MA0048` as build errors.

**K22-CODE-CS-08 (MUST)** Package versions are managed centrally in
`Directory.Packages.props`, every project commits its `packages.lock.json`, and CI
restores in locked mode (`RestoreLockedMode`, set automatically when `CI` or
`GITHUB_ACTIONS` is `true`). `NuGetAuditMode` is `all`, so a known-vulnerable direct or
transitive package fails the build.
*Why:* the dependency graph is pinned and reviewable (OSPS-QA-02.01) and drift fails
loudly. *Verified by:* restore in CI. *Maps to:* OSPS-QA-02.01, OSPS-BR-05.01.

**K22-CODE-CS-09 (MUST)** Builds are reproducible and debuggable from the package:
`Deterministic`, `ContinuousIntegrationBuild` in CI, SourceLink (built into the SDK),
and symbol packages (`.snupkg`) for libraries.
*Verified by:* `Directory.Build.props`.

**K22-CODE-CS-10 (MUST)** Structured logging (K22-CODE-19) uses the project's
`ILogger`-style abstraction with message templates (`"Synced {Repository}"`), never string
interpolation into the template, and never `Console.Write*` in library or app code
(command-line output of a CLI is not logging).
*Verified by:* `CA2254` (template should be static), review.

**K22-CODE-CS-11 (MUST)** Code that a test cannot run (native interop, process-level
hooks, network pass-throughs) is isolated in thin adapters marked
`[ExcludeFromCodeCoverage(Justification = "...")]`; all decisions around them live in
covered code.
*Verified by:* the coverage gate (K22-TEST); review of every new exclusion.

**K22-CODE-CS-12 (SHOULD)** Use modern C# where it reads better: file-scoped namespaces
(enforced), primary constructors, collection expressions, pattern matching, switch
expressions, records for data. These are IDE suggestions, not build errors.

**K22-CODE-CS-13 (SHOULD)** Async APIs end in `Async`, accept a `CancellationToken` when
the work can be long, and are not `async void` except event handlers. Library code uses
`ConfigureAwait(false)`; app code (UI threads) does not.
*Verified by:* Meziantou `MA0147`, `MA0134`, review.

## Commands

| Where | Command |
| --- | --- |
| Local, before pushing | `dotnet build -warnaserror` and `dotnet test` |
| Local, fix style | `dotnet format` (fixes formatting, `var`, usings, naming, modifier order) |
| CI build | `dotnet build <solution> -warnaserror` (locked restore) |
| CI style gate | `dotnet format <solution> --verify-no-changes --severity warn --no-restore` |
| CI tests | `dotnet test --collect:"XPlat Code Coverage" --settings coverage.runsettings` |
| CI security | CodeQL `csharp` with `build-mode: manual` (or `none` for libraries) |

## Adopting in an existing repository

Follow [`configs/dotnet/README.md`](../../configs/dotnet/README.md). For a sense of
scale: adopting this profile in AppKit (46 C# files) reported 3,316 findings, of
which `dotnet format` fixed 3,294 automatically (indentation, braces, keyword spacing,
`var`, unused usings, line endings). The remaining 22 were analyzer findings fixed by hand,
mostly splitting files that held more than one type.
