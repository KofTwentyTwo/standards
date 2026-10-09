# Rust

Implements the [Rust profile](../../standards/coding/rust.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`rustfmt.toml`](rustfmt.toml) | repository root | rustfmt: 3-space indent (`tab_spaces`), Unix newlines, stable options only |
| [`clippy.toml`](clippy.toml) | repository root | clippy thresholds, MSRV, disallowed print/debug macros |
| [`Cargo.lints.toml`](Cargo.lints.toml) | merge into `Cargo.toml` (`[lints]` or `[workspace.lints]`) | Lint levels: `unsafe_code` forbidden, pedantic warnings, no `unwrap`/`print` |
| [`deny.toml`](deny.toml) | repository root | cargo-deny: advisories, licenses, bans, sources |

## Use

```bash
cargo fmt                                                     # layout
cargo clippy --all-targets --all-features -- -D warnings      # lint
cargo install cargo-deny --locked && cargo deny check         # supply chain
```

CI runs `cargo fmt --check`, the clippy command with `--locked`, `cargo test --locked`,
and `cargo deny check`.

## IDEs

- **VS Code:** rust-analyzer formats with rustfmt and checks with clippy; see
  [`../vscode`](../vscode).
- **RustRover / IntelliJ Rust:** *Settings → Languages & Frameworks → Rust → Rustfmt* →
  **Use rustfmt instead of the built-in formatter** and run on save; *External Linters*
  → **Clippy**.

## Verified

rustfmt 1.9.0 (stable): `tab_spaces = 3` reformats a new crate to 3-space indentation;
`brace_style = "AlwaysNextLine"` is rejected on stable ("only available in nightly"),
which is why braces deviate (K22-CODE-RS-02). `cargo clippy -- -D warnings` runs clean
with `clippy.toml`. cargo-deny was not run here.
