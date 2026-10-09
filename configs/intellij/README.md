# IntelliJ IDEA and other JetBrains IDEs

The Kingsrook code style for every JetBrains IDE (IntelliJ IDEA, Rider for its non-C#
languages, WebStorm, PyCharm, DataGrip), plus Checkstyle and copyright setup.
Standards: [Java profile](../../standards/coding/java.md),
[coding README](../../standards/coding/README.md).

| File | What it is | Origin |
| --- | --- | --- |
| [`Kingsrook_Code_Style.xml`](Kingsrook_Code_Style.xml) | IDE code-style scheme: Java, JavaScript, TypeScript, JSON, XML, SQL, Shell, CSS, HTML, Groovy, VTL | Kingsrook (Apache-2.0), unmodified |
| `project/.idea/codeStyles/` (not yet published) | The same scheme as a per-project style, committed so the whole team gets it automatically | Derived from the above |
| `project/.idea/checkstyle-idea.xml` (not yet published) | CheckStyle-IDEA plugin settings pointing at the published KofTwentyTwo checkstyle config | KofTwentyTwo |
| `project/.idea/copyright/` (not yet published) + [`KofTwentyTwo_Copyright_Profile.xml`](KofTwentyTwo_Copyright_Profile.xml) | Copyright profile that inserts the KofTwentyTwo SPDX header (K22-CODE-24) | KofTwentyTwo |
| [`Kingsrook_Copyright_Profile.xml`](Kingsrook_Copyright_Profile.xml) | QQQ's own Apache-2.0 header, for QQQ-derived code only | Kingsrook, unmodified |
| [`live-templates/`](live-templates) | Kingsrook Java and SQL live templates (method, getter/setter/fluent setter, JUnit lifecycle, Liquibase changesets) | Kingsrook, unmodified |

## Per project (recommended)

Copy the contents of `project/.idea/` into the repository's `.idea/` folder and commit
`.idea/codeStyles/`, `.idea/checkstyle-idea.xml`, and `.idea/copyright/`. IntelliJ
picks them up on open: *Settings → Editor → Code Style* shows **Project** selected.

## Per IDE (all projects)

1. **Code style:** *Settings → Editor → Code Style → ⚙ (Show Scheme Actions) → Import
   Scheme → IntelliJ IDEA code style XML* → choose `Kingsrook_Code_Style.xml`.
2. **Reformat on save:** *Settings → Tools → Actions on Save* → enable **Reformat code**
   and **Optimize imports**.
3. **EditorConfig:** *Settings → Editor → Code Style → General* → keep **Enable
   EditorConfig support** on, so the repository `.editorconfig` (LF, final newline)
   applies.
4. **Copyright:** *Settings → Editor → Copyright → Copyright Profiles → +*, name it
   `KofTwentyTwo`, and paste the notice text from `KofTwentyTwo_Copyright_Profile.xml`
   (`Copyright (c) $today.year James Maes (KofTwentyTwo)` /
   `SPDX-License-Identifier: MIT`). Under *Formatting*, choose **Use block comment**,
   **Prefix each line**, and turn off the separator lines.
5. **Live templates:** copy a file's contents to the clipboard, open *Settings → Editor
   → Live Templates*, select (or create) a group named after the file, right-click it,
   and choose **Paste**.
6. **Comment generation:** install the
   [Kingsrook Commentator](https://plugins.jetbrains.com/plugin/19325-kingsrook-commentator)
   plugin for **Generate Header Comment** (banner Javadoc) and **Create Box Comment**
   (flower boxes).

## Checkstyle in the IDE

Install the **CheckStyle-IDEA** plugin. The committed `checkstyle-idea.xml` already
selects the KofTwentyTwo configuration at
`https://raw.githubusercontent.com/KofTwentyTwo/standards/main/configs/java/checkstyle/checkstyle.xml`
with Checkstyle 14.3.0. To set it up by hand: *Settings → Tools → Checkstyle → +* →
**Use a Checkstyle file accessible via HTTP** → paste the URL → mark it **Active**.

## Command line

IntelliJ can format headlessly, which CI can use to check JetBrains-only rules such as
three blank lines between methods:

```bash
idea format -s .idea/codeStyles/Project.xml -r -m '*.java' src
```

Checkstyle itself runs from the build; see [`../java`](../java).
