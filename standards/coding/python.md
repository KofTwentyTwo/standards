# Python profile

The [Kingsrook coding standard](README.md) applied to Python. Requirement IDs are
`K22-CODE-PY-NN`. Configuration: [`configs/python/`](../../configs/python).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| Interpreter | CPython 3.13+ | `requires-python` in `pyproject.toml`; `.python-version` |
| Project and environments | [uv](https://docs.astral.sh/uv/) with committed `uv.lock` | latest stable |
| Formatter **and** linter | [ruff](https://docs.astral.sh/ruff/) (`ruff format`, `ruff check`) | pinned in `pyproject.toml` dev dependencies |
| Type checker | pyright (strict) | pinned |
| Tests | pytest | latest stable |
| Coverage | coverage.py via `pytest-cov` | latest stable |
| Security | ruff `S` (bandit) rules; CodeQL `python`; `pip-audit` / dependency review | |

## Requirements

**K22-CODE-PY-01 (MUST)** Layout is `ruff format` with
[`ruff.toml`](../../configs/python/ruff.toml): **3-space indentation** (ruff's
`indent-width = 3`), LF, double quotes, effectively no line limit.
*Why Python keeps Kingsrook indentation:* ruff's formatter supports it fully, so the
Kingsrook rule is enforceable. The PEP 8 "multiple of four" checks are simply not
selected. *Verified by:* `ruff format --check` in CI.

**K22-CODE-PY-02 (MUST)** Deviation: Python blocks have no braces, so K22-CODE-04
(Allman) and K22-CODE-05 (`if(`) do not apply, and blank lines follow ruff's formatter (two
between top-level definitions, one between methods) because it caps blank lines and
cannot be configured to three. Every non-layout Kingsrook rule still applies.

**K22-CODE-PY-03 (MUST)** pyright runs in strict mode
([`pyrightconfig.json`](../../configs/python/pyrightconfig.json)) with zero errors, and
every function is fully annotated (ruff `ANN`).
*Verified by:* `pyright` in CI.

**K22-CODE-PY-04 (MUST)** `ruff check` passes with the KofTwentyTwo rule selection,
which includes the Kingsrook rules as lints: docstrings on modules, classes, and functions
(`D`), no commented-out code (`ERA`), no `print` (`T20`), tracked TODOs (`TD`, `FIX`),
no wildcard or relative imports, and bandit security rules (`S`).
*Verified by:* `ruff check` in CI.

**K22-CODE-PY-05 (MUST)** Header comments (K22-CODE-09) are docstrings, because Python
tooling (help, IDEs, documentation generators) reads only docstrings. Write them in the
Kingsrook plain "how and why" voice; inside functions, explanatory comments use the
flower-box shape with `#`:

```python
#########################################################
# the API pages at 100 items, so keep going until a     #
# short page comes back                                 #
#########################################################
```

**K22-CODE-PY-06 (MUST)** Logging uses the standard `logging` module (or `structlog`)
with structured fields (`LOG.info("synced", extra={"repository": name})`), lazy
formatting, and one module-level `LOG = logging.getLogger(__name__)`.
*Verified by:* ruff `G` and `LOG` rules.

**K22-CODE-PY-07 (MUST)** Environments and installs come from `uv.lock`
(`uv sync --locked` in CI). No `pip install` of unpinned packages in scripts or CI.
*Verified by:* the CI command. *Maps to:* OSPS-QA-02.01, OSPS-BR-05.01.

## Commands

| Where | Command |
| --- | --- |
| Local fix | `uv run ruff format . && uv run ruff check --fix .` |
| CI | `uv sync --locked`, `uv run ruff format --check .`, `uv run ruff check .`, `uv run pyright`, `uv run pytest --cov` |
