# EditorConfig (all languages)

[`.editorconfig`](.editorconfig) is the single file for a polyglot repository: UTF-8, LF,
final newline, trimmed whitespace, and the Kingsrook 3-space indentation everywhere,
except Go (tabs), Terraform/OpenTofu (2), YAML (2), and Makefiles (tabs). It includes
the shfmt keys and the complete C# rule set.

Single-language .NET repositories may use [`../dotnet/.editorconfig`](../dotnet)
instead; its `[*.cs]` sections are identical to this file's and must stay so (this file
is generated from it).

## Use

Copy to the repository root. EditorConfig is read natively by Visual Studio, Rider and
all JetBrains IDEs, Xcode 16+, and by VS Code with the EditorConfig extension, and by
`dotnet format`, shfmt, and many other formatters on the command line.
