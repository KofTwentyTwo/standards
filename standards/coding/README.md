# Coding standard: Kingsrook style, adopted

KofTwentyTwo writes code in the **Kingsrook code style**, the style of the
[QQQ](https://github.com/QRun-IO/qqq) project
([CODE_STYLE.md](https://github.com/QRun-IO/qqq/blob/develop/CODE_STYLE.md), Copyright
Kingsrook, LLC, Apache-2.0). This page restates those rules as numbered KofTwentyTwo
requirements, extends them from Java to every language we use, and adds the
security and quality rules every language shares. Attribution is in
[NOTICE](../../NOTICE).

Two principles from the original carry everything else:

- **The formatter owns layout.** Assume any code you write is reformatted the next time
  someone opens it, so hand-made formatting is lost. Layout is whatever the shared
  formatter configuration produces, and CI fails anything else.
- **Optimize for the next reader.** Verbose names, a header comment on every type and
  method, flower-box comments that explain *why*, and room for the code to breathe.

Each language's profile says exactly how the rules are enforced in that language, and
where a language's own mandatory formatter makes a Kingsrook layout rule impossible, the
profile states the deviation as a rule of its own.

## Language profiles

| Language | Profile | ID prefix | Kingsrook layout | Enforced by |
| --- | --- | --- | --- | --- |
| C# / .NET | [csharp-dotnet.md](csharp-dotnet.md) | `K22-CODE-CS` | Full | `dotnet build` (analyzers + style), `dotnet format` |
| Java | [java.md](java.md) | `K22-CODE-JV` | Full (the origin) | Checkstyle, IntelliJ scheme |
| TypeScript / JavaScript | [typescript.md](typescript.md) | `K22-CODE-TS` | Full | ESLint + `@stylistic`, `tsc` |
| Python | [python.md](python.md) | `K22-CODE-PY` | Indent only (no braces) | ruff, pyright |
| Rust | [rust.md](rust.md) | `K22-CODE-RS` | Indent; braces deviate | rustfmt, clippy, cargo-deny |
| Swift | [swift.md](swift.md) | `K22-CODE-SW` | Indent; braces deviate | swift-format, SwiftLint |
| Shell / PowerShell | [shell.md](shell.md) | `K22-CODE-SH` | Bash: indent; PowerShell: full | shfmt, ShellCheck, PSScriptAnalyzer |
| Go | [go.md](go.md) | `K22-CODE-GO` | Deviates (gofmt) | gofmt, golangci-lint, govulncheck |
| Terraform / OpenTofu | [terraform.md](terraform.md) | `K22-CODE-TF` | Deviates (`fmt`) | `tofu fmt`, TFLint, Trivy |
| SQL | this page, [SQL](#sql) | `K22-CODE-*` | Full | sqlfluff, IntelliJ scheme |

Every configuration file a tool or IDE imports is in [`configs/`](../../configs), one
folder per language or tool, each with a README on how to apply it.

## Tooling

**K22-CODE-01 (MUST)** Every repository runs its language's formatter and linters with
the KofTwentyTwo configuration from [`configs/`](../../configs), both locally (build,
pre-commit, or save) and in CI, and CI fails on any finding.
*Why:* style that is only checked in review drifts; one configuration in both places
means CI never surprises anyone. *Verified by:* the profile's CI commands as required
status checks. *Maps to:* SSDF PW.5.1, PW.7.2.

**K22-CODE-02 (MUST)** Compiler and analyzer warnings are errors. A suppression is
written at the narrowest scope (one line or member) with a comment that says why.
*Why:* a warning nobody fixes trains everyone to ignore warnings. *Verified by:* the
profile's warnings-as-errors setting. *Maps to:* SSDF PW.6.2.

## Layout (Kingsrook)

**K22-CODE-03 (MUST)** Indentation is 3 spaces per level, never tabs.
*Verified by:* the language formatter (configured to 3) and `.editorconfig`. Deviations:
Go (tabs) and Terraform/OpenTofu (2 spaces), whose formatters are fixed; YAML (2 spaces).

**K22-CODE-04 (MUST)** Opening braces go on the next line, under the start of the
declaration or statement, for types, methods, and blocks (Allman style). Closing braces
stand alone, and `else`, `catch`, and `finally` start a new line.
*Verified by:* the language formatter or linter. Deviations are listed per profile:
Rust, Swift, and Go keep same-line braces because their formatters cannot do otherwise.

**K22-CODE-05 (MUST)** There is no space between a control-flow keyword and its
parenthesis: `if(ready)`, `for(...)`, `while(...)`, `catch(...)`, `switch(...)`.
*Verified by:* the formatter where it can express it (C#, Java via IntelliJ,
TypeScript); review elsewhere. Languages whose formatter requires the space keep it.

**K22-CODE-06 (MUST)** Inside a block of code there is never more than one consecutive
blank line; use single blank lines to separate logical groups of statements. Methods and
other members are separated by three blank lines.
*Why:* let the code breathe, and make each method a visibly separate unit.
*Verified by:* the JetBrains scheme, ESLint, and the profile's formatter where it can
count blank lines; review otherwise.

**K22-CODE-07 (MUST)** Text files are UTF-8 with LF line endings, a final newline, and no
trailing whitespace, set by [`.editorconfig`](../../configs/editorconfig/.editorconfig)
and `.gitattributes` (`* text=auto eol=lf`). Windows `.cmd` and `.bat` files are CRLF.
*Verified by:* the formatter's whitespace check in CI.

**K22-CODE-08 (MUST)** No line-length limit is enforced. Long statements, especially
fluent chains, are broken by meaning, with the `.` or the operator starting the
continuation line.
*Verified by:* line-length rules are disabled in every configuration; operator and dot
placement is checked where the linter supports it.

## Comments

**K22-CODE-09 (MUST)** Every type and every method or function has a header comment
directly above it (no blank line between), even if it is only a visual break. Write the
*how and why*; describe the *what* only when the code does not make it obvious. Plain text
is preferred over tags and markup. The comment's form is the Kingsrook banner where the
language allows it, and the language's documentation-comment syntax where tooling depends
on it; each profile shows its form. The banner is:

```java
/*******************************************************************************
 ** Transform step that evaluates orders before they are released to the warehouse.
 *******************************************************************************/
public class EvaluateOrdersTransformStep implements AbstractTransformStep
```

Line one is `/` followed by `*` to 80 characters, body lines start with ` ** `, and the
last line is a space, `*` to 80 characters, and `/`. The
[Kingsrook Commentator](https://plugins.jetbrains.com/plugin/19325-kingsrook-commentator)
IntelliJ plugin generates both comment forms.
*Verified by:* Checkstyle (Java), `CS1591` (C# public API), `D`/missing-docs lints
(Python, Rust, Swift); review for the rest.

**K22-CODE-10 (SHOULD)** Comments inside a type or method body are flower boxes: a line
of `/`, the text between `//` and `//` (one space inside each) padded so every line is the same length, and a
closing line of `/`.

```java
/////////////////////////////////////////////////////////////////////////
// preload all data that will be needed for optimizations.             //
// note - if we ever "optimize" this to only load the ones needed ("on //
// this page"), we'd then need to re-fetch/update/clear/etc something  //
/////////////////////////////////////////////////////////////////////////
preloadOrderData(runBackendStepInput);
```

Languages without `//` comments use their own comment character in the same shape.

**K22-CODE-11 (MUST)** No zombie code: code that is commented out instead of deleted.
Version control keeps old code. If a commented-out block is genuinely worth keeping, a
flower box above it says why.
*Verified by:* ruff `ERA`, review elsewhere.

**K22-CODE-12 (MUST)** A `TODO` or `FIXME` names the GitHub issue that tracks it
(`// TODO(#123): ...`). Untracked work is not left in code.
*Verified by:* linters where available (ruff `TD`/`FIX`, ESLint `no-warning-comments`
with the issue pattern, SwiftLint `todo`), review elsewhere.

## Naming

**K22-CODE-13 (MUST)** Names are long and descriptive rather than short and abbreviated.
Short names are acceptable for loop indexes and caught exceptions. No Hungarian notation
(`strZipCode`); suffixes that state the shape (`orderList`, `customerMap`) are fine.
Casing follows the language profile; database columns are `lower_snake_case`.
*Verified by:* naming analyzers per profile, review.

## Imports

**K22-CODE-14 (MUST)** No wildcard imports. Statically import (or otherwise bring into
scope unqualified) only utilities used throughout the codebase, such as test assertions
or the logging helper; use qualified references for specialized utilities so a reader
does not mistake them for local code.
*Verified by:* Checkstyle `AvoidStarImport`, ruff `F403`, ESLint, review.

## Design

**K22-CODE-15 (SHOULD)** Prefer fluent APIs (`order.withId(id).withStatus(status)`) over
sequences of setters on a variable; they read better and prevent setting a value on the
wrong instance.

**K22-CODE-16 (SHOULD)** Balance method length: neither one thousand-line method nor a
hundred five-line methods that force the reader to jump around. Around fifty lines is a
reasonable upper guide; the profile's analyzer threshold flags extremes.

**K22-CODE-17 (SHOULD)** Code that touches the outside world (files, network, clock,
process, UI) sits behind an interface or injected dependency, so the logic around it is
unit-testable without that world. Prefer this to statics and singletons.

**K22-CODE-18 (MUST)** Compare values by value: Java `.equals` or `Objects.equals` (never
`==` on boxed types or strings), C# `string.Equals` with an explicit comparison,
TypeScript `===`.
*Verified by:* analyzers per profile (Error Prone, Meziantou `MA0006`, ESLint `eqeqeq`).

## Logging and errors

**K22-CODE-19 (MUST)** Logging is structured: a message plus key/value pairs, through the
project's logger. Never write diagnostics to standard output or standard error
(`System.out`, `Console.WriteLine`, `print`, `println!`, `fmt.Println`) or print stack
traces; log the exception object instead. `warn` and `error` mean an engineer should act:
roughly 95% of actionable problems are `warn` (one record failed), `error` is reserved
for systemic failure (the database is unreachable).
*Verified by:* banned-API rules per profile (Checkstyle, ruff `T20`, clippy
`print_stdout`, ESLint `no-console`, golangci `forbidigo`, SwiftLint custom rule).

**K22-CODE-20 (MUST)** Errors are never swallowed. An empty `catch` is allowed only when
the exception is expected and the block says so (a comment, or an exception variable
named `expected`). A rethrown or wrapped exception keeps its cause.
*Verified by:* Checkstyle `EmptyCatchBlock`, ruff `BLE`/`S110`, analyzers per profile.

## Security

**K22-CODE-21 (MUST)** No secrets, credentials, tokens, or personal data in source,
tests, fixtures, comments, or log messages. Secrets come from the environment or the
platform secret store at run time.
*Verified by:* gitleaks in pre-commit and CI; GitHub push protection. *Maps to:*
OSPS-BR-07.01, SSDF PW.5.1.

**K22-CODE-22 (MUST)** Input from outside the process is validated where it enters
(parse, don't trust). Queries are parameterized, never built by string concatenation;
external commands are run with argument arrays, never through a shell string.
*Verified by:* CodeQL and the profile's security linters (bandit rules in ruff, gosec,
Meziantou, Error Prone). *Maps to:* SSDF PW.5.1.

**K22-CODE-23 (MUST)** Nullability and type checking run at their strictest setting
(C# nullable reference types, TypeScript `strict`, pyright strict, Java NullAway, Swift 6
language mode).
*Verified by:* the profile's compiler or type-checker configuration.

## Files and generated code

**K22-CODE-24 (MUST for Java, SHOULD elsewhere)** Every source file starts with a license
header: a copyright line and an [SPDX](https://spdx.dev/learn/handling-license-info/)
license identifier.

```text
/*
 * Copyright (c) 2026 James Maes (KofTwentyTwo)
 * SPDX-License-Identifier: MIT
 */
```

*Verified by:* Checkstyle `RegexpHeader` (Java); IntelliJ copyright profile
([configs/intellij](../../configs/intellij)) inserts it everywhere.

**K22-CODE-25 (MUST)** Generated code is excluded from formatting, linting, and coverage
only through an explicit marker (a `generated` directory, a `GeneratedCode` attribute, a
`// <auto-generated>` header, an ignore entry naming the path), never by weakening a rule
for hand-written code.
*Verified by:* review of linter and coverage configuration changes.

**K22-CODE-26 (MUST)** Public API of a published library is documented, and the build
fails when a public member has no documentation comment.
*Verified by:* `CS1591` (C#), `missing_docs` (Rust), ruff `D` (Python), SwiftLint
`missing_docs`, Checkstyle `MissingJavadoc*`.

## SQL

SQL follows the Kingsrook IntelliJ SQL scheme: 3-space indentation, upper-case
keywords, lower-case `snake_case` identifiers. Migrations are versioned files run by the
project's migration tool (the Kingsrook live templates include Liquibase changesets), and
never edited after they have shipped. Enforced by
[`configs/sql/.sqlfluff`](../../configs/sql/.sqlfluff) (`sqlfluff lint` in CI).
