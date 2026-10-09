# Go

Implements the [Go profile](../../standards/coding/go.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`.golangci.yml`](.golangci.yml) | repository root | golangci-lint v2: gofmt + goimports formatters; standard linters plus security, error-handling, `slog` key/value, and banned `fmt.Print*` |

Go keeps gofmt's layout (tabs, same-line braces); see K22-CODE-GO-02.

## Use

```bash
golangci-lint fmt          # layout
golangci-lint run --fix    # lint
govulncheck ./...          # reachable vulnerabilities
```

CI: `golangci-lint fmt --diff`, `golangci-lint run`, `go test -race ./...`,
`govulncheck ./...`.

## IDEs

- **VS Code:** Go extension with `go.lintTool: golangci-lint`; see [`../vscode`](../vscode).
- **GoLand:** *Settings → Tools → Actions on Save* → **Reformat code** and **Optimize
  imports**; *Settings → Tools → golangci-lint* → point at the repository config.

## Verified

Written against the golangci-lint v2 configuration schema; not run here (no Go
toolchain installed).
