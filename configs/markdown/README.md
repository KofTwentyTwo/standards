# Markdown

[`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc) configures
[markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) for every
repository: all default rules, except no line-length limit (`K22-CODE-08`), a short list
of allowed HTML elements, and repeated headings allowed under different parents.

- **Command line:** copy the file to the repository root and run
  `npx markdownlint-cli2 "**/*.md"`.
- **VS Code:** the *markdownlint* extension (`DavidAnson.vscode-markdownlint`) reads the
  same file.
- **JetBrains IDEs:** the built-in Markdown inspections are independent; rely on the
  pre-commit hook or CI for markdownlint.
- **CI:** the `docs` job in this repository's `ci.yml` shows how to run it pinned.
