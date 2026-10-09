# Go profile

The [Kingsrook coding standard](README.md) applied to Go. Requirement IDs are
`K22-CODE-GO-NN`. Configuration: [`configs/go/`](../../configs/go).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| Toolchain | Go (latest two releases supported upstream) | `go` and `toolchain` directives in `go.mod` |
| Formatter | gofmt + goimports (via `golangci-lint fmt`) | toolchain |
| Linter | [golangci-lint v2](https://golangci-lint.run) with [`.golangci.yml`](../../configs/go/.golangci.yml) | pinned version in CI |
| Vulnerabilities | `govulncheck` | latest |
| Tests | `go test -race` | toolchain |
| Coverage | `go test -coverprofile` | toolchain |

## Requirements

**K22-CODE-GO-01 (MUST)** `golangci-lint fmt --diff` and `golangci-lint run` pass with
zero findings.
*Verified by:* CI.

**K22-CODE-GO-02 (MUST)** Deviation: layout is exactly gofmt's: tabs for indentation,
same-line braces, a space after `if`. gofmt is not configurable, the compiler's
semicolon insertion makes next-line braces a syntax error, and every Go tool assumes
gofmt output. K22-CODE-03 through K22-CODE-06 therefore do not apply to Go. Every
non-layout Kingsrook rule still applies.

**K22-CODE-GO-03 (MUST)** Header comments (K22-CODE-09) are Go doc comments starting
with the identifier's name, on every exported and unexported type and function; the
`godot` and `revive` `exported` rules enforce them for exported API.

**K22-CODE-GO-04 (MUST)** Logging uses `log/slog` with key/value attributes only
(`sloglint kv-only`); `fmt.Print*` and `print` are banned outside `main` CLI output
(`forbidigo`).
*Verified by:* golangci-lint.

**K22-CODE-GO-05 (MUST)** Errors are wrapped with context (`fmt.Errorf("...: %w", err)`)
and compared with `errors.Is`/`errors.As`; `gosec`, `errorlint`, and `wrapcheck` pass.
`govulncheck ./...` reports no reachable vulnerabilities.
*Verified by:* CI. *Maps to:* OSPS-VM-05.03.

## Commands

| Where | Command |
| --- | --- |
| Local fix | `golangci-lint fmt && golangci-lint run --fix` |
| CI | `golangci-lint fmt --diff`, `golangci-lint run`, `go test -race -coverprofile=coverage.out ./...`, `govulncheck ./...` |
