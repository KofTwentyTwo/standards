# Eclipse formatter

[`eclipse-formatter.xml`](eclipse-formatter.xml) is the Kingsrook Eclipse formatter
profile (`Kingsrook-Eclipse`): 3-space indentation with spaces, and next-line braces for
types, methods, constructors, blocks, `switch`, and enums. Origin: Kingsrook (qctl),
Apache-2.0, unmodified.

It sets only the layout settings that differ from Eclipse's defaults, so it is the
lightweight companion to the full IntelliJ scheme; Checkstyle
([`../java`](../java)) is the authority in CI.

## Eclipse

*Window → Preferences → Java → Code Style → Formatter → Import…* → choose
`eclipse-formatter.xml` → **Apply**. Enable *Java → Editor → Save Actions → Format source
code* to format on save.

## VS Code (Language Support for Java by Red Hat)

The extension uses Eclipse formatter profiles:

```jsonc
"java.format.settings.url": "https://raw.githubusercontent.com/KofTwentyTwo/standards/main/configs/eclipse/eclipse-formatter.xml",
"java.format.settings.profile": "Kingsrook-Eclipse"
```

(already in [`../vscode/settings.json`](../vscode/settings.json)).

## Command line (optional)

[Spotless](https://github.com/diffplug/spotless) can apply the same profile in a build
(`eclipse().configFile("eclipse-formatter.xml")`). It is optional: the profile does not
cover every Kingsrook rule (for example `if(` with no space), so Checkstyle remains the
required gate (K22-CODE-JV-02).
