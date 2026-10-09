# Java

Build-time enforcement of the [Java profile](../../standards/coding/java.md).

| File | Purpose |
| --- | --- |
| [`checkstyle/checkstyle.xml`](checkstyle/checkstyle.xml) | **The KofTwentyTwo Checkstyle config.** Kingsrook rules plus the KofTwentyTwo SPDX header and a ban on `System.out`/`System.err`/`printStackTrace()`. Self-contained, so it also works from its URL |
| [`checkstyle/kingsrook/`](checkstyle/kingsrook) | Kingsrook's original config and QQQ license header, unmodified, for QQQ-derived projects |
| [`maven-checkstyle.xml`](maven-checkstyle.xml) | Maven plugin block: Checkstyle 14.3.0 in the `validate` phase, failing on any warning |
| [`gradle-checkstyle.gradle.kts`](gradle-checkstyle.gradle.kts) | Gradle equivalent: `checkstyle` plugin, `maxWarnings = 0` |
| [`license-header.txt`](license-header.txt) | The source header (`$YEAR` placeholder) for tools that insert headers (Spotless `licenseHeaderFile`, IDE templates) |

Published URL (always the latest on `main`):
`https://raw.githubusercontent.com/KofTwentyTwo/standards/main/configs/java/checkstyle/checkstyle.xml`

## Maven

1. Copy `checkstyle/checkstyle.xml` to `checkstyle/checkstyle.xml` in the repository (a
   local copy keeps builds reproducible; update it when this repository releases).
2. Paste the `<plugin>` block from `maven-checkstyle.xml` into `<build><plugins>`.
3. `./mvnw -B verify` now fails on any violation, locally and in CI.

## Gradle

Copy `checkstyle/checkstyle.xml` as above, then add the contents of
`gradle-checkstyle.gradle.kts` to `build.gradle.kts`. `./gradlew check` fails on any
violation.

## IDEs

- **IntelliJ:** see [`../intellij`](../intellij) (code-style scheme + CheckStyle-IDEA).
- **Eclipse:** import [`../eclipse/eclipse-formatter.xml`](../eclipse) and install the
  Checkstyle plug-in pointed at the URL above.
- **VS Code:** [`../vscode/settings.json`](../vscode) sets `java.format.settings.url` and
  `java.checkstyle.configuration` to the published files.

## Verified

Checkstyle 14.3.0 (CLI and `maven-checkstyle-plugin` 3.6.0 on Maven 3.9.16, JDK 21):
a Kingsrook-style file passes; a file with 4-space indentation, same-line braces, a star
import, no banner Javadoc, `System.out`, `printStackTrace()`, and no SPDX header fails
with 17 violations. The Gradle snippet follows Gradle's documented `checkstyle` plugin
API and was not run here (no Gradle installation).
