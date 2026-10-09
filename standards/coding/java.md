# Java profile

Java is where the [Kingsrook style](README.md) comes from, so every rule applies
unchanged. Requirement IDs are `K22-CODE-JV-NN`. Configuration:
[`configs/java/`](../../configs/java), [`configs/intellij/`](../../configs/intellij),
[`configs/eclipse/`](../../configs/eclipse).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| JDK | Java 21 LTS or later LTS | Toolchain declared in the build |
| Build | Maven 3.9+ or Gradle 8+ | Wrapper committed (`mvnw` / `gradlew`) |
| Formatter | IntelliJ with the Kingsrook scheme ("Reformat Code" on save); Eclipse formatter profile for Eclipse / VS Code | Scheme in `configs/intellij` |
| Style gate | Checkstyle with [`configs/java/checkstyle/checkstyle.xml`](../../configs/java/checkstyle/checkstyle.xml) | Checkstyle 14.x, pinned in the build |
| Bug and null analysis | Error Prone with NullAway | latest stable, pinned in the build |
| Tests | JUnit 5 (Jupiter), AssertJ or JUnit assertions | latest stable |
| Coverage | JaCoCo | latest stable |
| Security | CodeQL `java-kotlin` (`security-extended`); dependency review; Trivy | GitHub-managed / pinned image |

## Requirements

**K22-CODE-JV-01 (MUST)** Developers format with the Kingsrook IntelliJ scheme
([`Kingsrook_Code_Style.xml`](../../configs/intellij/Kingsrook_Code_Style.xml), or the
committed `.idea/codeStyles/Project.xml`) with *Actions on Save → Reformat code* enabled.
Eclipse and VS Code users use the Kingsrook Eclipse formatter profile.
*Verified by:* Checkstyle (K22-CODE-JV-02) catches what the formatter would have fixed.

**K22-CODE-JV-02 (MUST)** Checkstyle runs in the build's `validate` phase (Maven) or
`check` task (Gradle) with the KofTwentyTwo configuration and fails the build on any
violation, locally and in CI. It enforces the Kingsrook rules: 3-space indentation, no
tabs, next-line braces, no star imports, banner Javadoc on every type and method, import
order, operator and dot wrapping on the new line, naming patterns, the SPDX license
header, and no `System.out` / `System.err` / `printStackTrace()`.
*Verified by:* the build ([Maven](../../configs/java/maven-checkstyle.xml) /
[Gradle](../../configs/java/gradle-checkstyle.gradle.kts) snippets).

**K22-CODE-JV-03 (MUST)** Header comments are the Kingsrook banner Javadoc
(K22-CODE-09), with plain text preferred over `@param`/`@return` tags. Three blank lines
separate methods; two blank lines follow the package statement and surround the import
block (Kingsrook IntelliJ scheme).
*Verified by:* Checkstyle `MissingJavadocMethod`/`MissingJavadocType`; the IntelliJ
scheme.

**K22-CODE-JV-04 (MUST)** Use wrapper types (`Integer`, `Boolean`, `Long`) rather than
primitives for fields, parameters, and return values that carry application data, because
data often comes from a database where it can be null. A primitive is acceptable in a
performance-sensitive loop after profiling shows it matters.
*Verified by:* review.

**K22-CODE-JV-05 (MUST)** Compare objects, including boxed numbers and strings, with
`.equals` or `Objects.equals(a, b)`, never `==`.
*Verified by:* Error Prone (`ReferenceEquality`, `StringEquality`, `BoxedPrimitiveEquality`).

**K22-CODE-JV-06 (MUST)** Error Prone runs as part of compilation with NullAway in
`ERROR` mode for the project's packages, and warnings fail the build (`-Werror`).
*Verified by:* the compiler configuration.

**K22-CODE-JV-07 (SHOULD)** Classes with several properties offer fluent `withX(...)`
setters returning `this` (the Kingsrook `gsw` live template generates getter, setter, and
fluent setter).

**K22-CODE-JV-08 (MUST)** Logging is structured key/value logging through the project's
logger (for example SLF4J 2's fluent API, `log.atInfo().addKeyValue("orderId",
id).log("released")`, or QQQ's `QLogger` with `logPair`). One logger per class:
`private static final Logger LOG = ...`.
*Verified by:* Checkstyle `NoSystemOutOrErr`, `NoPrintStackTrace`.

**K22-CODE-JV-09 (MUST)** Statically import only ubiquitous utilities (test assertions,
the logging pair helper, a core enum); qualify everything else (K22-CODE-14).
*Verified by:* review.

**K22-CODE-JV-10 (SHOULD)** Use the Kingsrook live templates
([`configs/intellij/live-templates`](../../configs/intellij/live-templates)) for
methods, getters/setters, and test lifecycle methods, so generated code already matches
the style. Note that the `tcp`/`tcpr` templates emit `e.printStackTrace()`; replace it
with a log call (K22-CODE-JV-08), which Checkstyle requires anyway.

## Commands

| Where | Maven | Gradle |
| --- | --- | --- |
| Local / CI build with style gate | `./mvnw -B verify` | `./gradlew check` |
| Style only | `./mvnw -B checkstyle:check` | `./gradlew checkstyleMain checkstyleTest` |
| Coverage report | `./mvnw -B verify` (JaCoCo `report` + `check` goals) | `./gradlew jacocoTestReport jacocoTestCoverageVerification` |
