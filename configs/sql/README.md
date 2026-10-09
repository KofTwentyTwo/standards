# SQL

[`.sqlfluff`](.sqlfluff) applies the Kingsrook IntelliJ SQL settings on the command line:
3-space indentation, upper-case keywords, functions, and types, lower-case
identifiers, no line limit. Set `dialect` for the repository's database.

## Use

```bash
uv tool install sqlfluff
sqlfluff lint     # CI
sqlfluff fix      # local
```

## IDEs

- **DataGrip / IntelliJ:** the Kingsrook scheme ([`../intellij`](../intellij)) sets the
  same SQL style; the Kingsrook SQL live templates add Liquibase changeset snippets.
- **VS Code:** the sqlfluff extension reads this file.

## Verified

Written against the sqlfluff configuration schema; not run here.
