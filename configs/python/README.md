# Python

Implements the [Python profile](../../standards/coding/python.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`ruff.toml`](ruff.toml) | repository root (or merge into `[tool.ruff]` in `pyproject.toml`) | Formatter (3-space indent, LF) and linter rule set (Kingsrook rules as lints, bandit security rules) |
| [`pyrightconfig.json`](pyrightconfig.json) | repository root (or `[tool.pyright]`) | Strict type checking |

## Use

```bash
uv add --dev ruff pyright pytest pytest-cov
uv run ruff format .          # layout
uv run ruff check --fix .     # lint
uv run pyright                # types
```

CI: `uv sync --locked`, `uv run ruff format --check .`, `uv run ruff check .`,
`uv run pyright`, `uv run pytest --cov`.

## IDEs

- **VS Code:** Ruff extension as the formatter, Pylance in strict mode; see
  [`../vscode`](../vscode).
- **PyCharm / IntelliJ:** install the **Ruff** plugin (or use PyCharm's built-in Ruff
  support), enable *Format on save* with Ruff, and set *Editor → Code Style → Python →
  Indent* to 3 (ruff reads `ruff.toml` regardless).

## Verified

ruff 0.16.10: `indent-width = 3` reformats a 4-space file to 3 spaces cleanly and the
lint passes; a file with an unused import, commented-out code, `print`, and no
annotations or docstrings fails on each (`F401`, `ERA001`, `T201`, `ANN*`, `D*`).
pyright strict was not run here.
