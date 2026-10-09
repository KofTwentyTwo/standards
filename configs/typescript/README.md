# TypeScript / JavaScript

Implements the [TypeScript profile](../../standards/coding/typescript.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`eslint.config.mjs`](eslint.config.mjs) | repository root | ESLint flat config: typescript-eslint `strictTypeChecked` + ESLint Stylistic for the Kingsrook layout (3-space indent, Allman braces, `if(`) |
| [`tsconfig.json`](tsconfig.json) | `tsconfig.k22.json`, extended by the project's `tsconfig.json` | Strict compiler baseline |

## Install

```bash
npm i -D eslint @eslint/js typescript-eslint @stylistic/eslint-plugin typescript
```

TypeScript resolves to the newest version typescript-eslint supports (6.x in October
2026; TypeScript 7 once typescript-eslint adds support).

## Use

| Where | Command |
| --- | --- |
| Fix layout and lint | `npx eslint . --fix` |
| CI | `npx eslint . --max-warnings 0` and `npx tsc --noEmit` |

Add `"lint": "eslint . --max-warnings 0"` and `"typecheck": "tsc --noEmit"` to
`package.json` scripts.

## IDEs

- **VS Code:** ESLint extension as the formatter; see [`../vscode`](../vscode).
- **WebStorm / IntelliJ:** *Settings → Languages & Frameworks → JavaScript → Code
  Quality Tools → ESLint* → **Automatic ESLint configuration** and **Run eslint --fix on
  save**. The Kingsrook IntelliJ scheme ([`../intellij`](../intellij)) already sets
  TypeScript and JavaScript to 3-space indentation and next-line braces.
- **Do not use Prettier**: it cannot produce next-line braces and would fight ESLint.

## Verified

ESLint 10.12.0, typescript-eslint 8.71.1, @stylistic/eslint-plugin 5.10.0, TypeScript
6.0.3: a Kingsrook-style class passes; a file with same-line braces, 4-space indentation,
`if (`, missing semicolons, `==`, `console.log`, and no return type fails on each.
