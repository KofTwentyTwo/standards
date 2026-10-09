# TypeScript / JavaScript profile

The [Kingsrook coding standard](README.md) applied to TypeScript and JavaScript.
Requirement IDs are `K22-CODE-TS-NN`. Configuration:
[`configs/typescript/`](../../configs/typescript).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| Runtime | Node.js active LTS | `.nvmrc` / `engines` in `package.json` |
| Package manager | npm or pnpm with a committed lock file | `packageManager` field pinned |
| Compiler / type checker | TypeScript | the newest version typescript-eslint supports (6.x as of October 2026; 7.x when supported) |
| Lint **and layout** | ESLint 10 flat config + [typescript-eslint](https://typescript-eslint.io) `strictTypeChecked` + [ESLint Stylistic](https://eslint.style) | latest stable, pinned in lock file |
| Tests | Vitest | latest stable |
| Coverage | Vitest V8 coverage | latest stable |
| Security | CodeQL `javascript-typescript`; `npm audit signatures`; dependency review | |

Prettier is **not** used: it cannot place braces on the next line, so it cannot produce
the Kingsrook layout. ESLint Stylistic formats instead (`eslint --fix`).

## Requirements

**K22-CODE-TS-01 (MUST)** The repository uses
[`eslint.config.mjs`](../../configs/typescript/eslint.config.mjs), which enforces the
Kingsrook layout: 3-space indent, Allman braces, `if(`/`for(`/`while(`/`switch(`/`catch(`
with no space, double quotes, semicolons, dots and operators leading continuation lines,
and at most three consecutive blank lines (one inside blocks by convention, three between
members). `eslint --max-warnings 0` gates CI.
*Verified by:* ESLint in CI and on save.

**K22-CODE-TS-02 (MUST)** Type-aware strict linting: `strictTypeChecked` and
`stylisticTypeChecked` from typescript-eslint, explicit return types on functions,
`eqeqeq`, `curly`, no `console`, and naming conventions (camelCase values, PascalCase
types).
*Verified by:* ESLint.

**K22-CODE-TS-03 (MUST)** `tsconfig.json` extends the
[strict baseline](../../configs/typescript/tsconfig.json): `strict`,
`noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`,
`noUnusedLocals`/`Parameters`, `verbatimModuleSyntax`. `tsc --noEmit` passes in CI.
*Verified by:* `tsc --noEmit`.

**K22-CODE-TS-04 (MUST)** Header comments are the Kingsrook banner in JSDoc position,
so editors still show them on hover:

```ts
/*******************************************************************************
 ** Builds greetings for a list of people.
 *******************************************************************************/
export class Greeter
```

*Verified by:* review.

**K22-CODE-TS-05 (MUST)** No `any` in hand-written code (use `unknown` and narrow), no
non-null assertions (`!`) without a comment, no floating promises.
*Verified by:* typescript-eslint `no-explicit-any`, `no-non-null-assertion`,
`no-floating-promises`.

**K22-CODE-TS-06 (MUST)** Dependencies are installed from the committed lock file in CI
(`npm ci` / `pnpm install --frozen-lockfile`), with lifecycle scripts disabled unless a
dependency needs them (`--ignore-scripts`, with an allow-list).
*Why:* install scripts are the most common malware vector in the npm ecosystem.
*Verified by:* the CI command. *Maps to:* OSPS-BR-05.01.

## Commands

| Where | Command |
| --- | --- |
| Local fix | `npx eslint . --fix` |
| CI lint | `npx eslint . --max-warnings 0` |
| CI types | `npx tsc --noEmit` |
| CI tests | `npx vitest run --coverage` |
