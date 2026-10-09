# Rust profile

The [Kingsrook coding standard](README.md) applied to Rust. Requirement IDs are
`K22-CODE-RS-NN`. Configuration: [`configs/rust/`](../../configs/rust).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| Toolchain | stable Rust via `rust-toolchain.toml` | pinned stable version; MSRV declared in `Cargo.toml` (`rust-version`) |
| Formatter | rustfmt with [`rustfmt.toml`](../../configs/rust/rustfmt.toml) | stable options only |
| Linter | clippy (`-D warnings`, `pedantic` as warnings) | toolchain version |
| Supply chain | [cargo-deny](https://github.com/EmbarkStudios/cargo-deny) (advisories, licenses, bans, sources) | latest stable |
| Tests | `cargo test` (`cargo nextest` optional) | |
| Coverage | `cargo llvm-cov` | latest stable |

## Requirements

**K22-CODE-RS-01 (MUST)** `cargo fmt --check` passes with the KofTwentyTwo
`rustfmt.toml`: **3-space indentation** (`tab_spaces = 3`, a stable option), Unix line
endings, `max_width = 200`.
*Verified by:* `cargo fmt --check` in CI.

**K22-CODE-RS-02 (MUST)** Deviation: braces stay on the same line (rustfmt's default).
`brace_style = "AlwaysNextLine"` and blank-line limits exist only on the nightly
toolchain, and KofTwentyTwo does not build release code with nightly. K22-CODE-04 and
K22-CODE-06 (blank-line counts) therefore follow rustfmt; every non-layout Kingsrook rule
still applies.

**K22-CODE-RS-03 (MUST)** Header comments (K22-CODE-09) are `///` doc comments on every
item and `//!` on every module, because rustdoc and `missing_docs` read only those.
Inside function bodies, explanatory comments use the flower-box shape.
*Verified by:* `missing_docs` lint (warn → error under `-D warnings`).

**K22-CODE-RS-04 (MUST)** `cargo clippy --all-targets --all-features -- -D warnings`
passes with the lint table in
[`Cargo.lints.toml`](../../configs/rust/Cargo.lints.toml) and thresholds in
[`clippy.toml`](../../configs/rust/clippy.toml): `unsafe_code` forbidden, `unwrap`/
`expect` flagged outside tests, `println!`/`eprintln!`/`dbg!` disallowed (use `tracing`
with structured fields).
*Verified by:* clippy in CI.

**K22-CODE-RS-05 (MUST)** `cargo deny check` passes with
[`deny.toml`](../../configs/rust/deny.toml): no known advisories or yanked crates, only
permissive licenses, no wildcard versions, crates only from crates.io. `Cargo.lock` is
committed for binaries and libraries alike.
*Verified by:* cargo-deny in CI. *Maps to:* OSPS-QA-02.01, OSPS-VM-05.03.

**K22-CODE-RS-06 (MUST)** Errors are typed (`thiserror` for libraries, `anyhow` or
`eyre` at application edges) and carry context; panics are for broken invariants only.
*Verified by:* clippy `unwrap_used`, `expect_used`; review.

## Commands

| Where | Command |
| --- | --- |
| Local fix | `cargo fmt && cargo clippy --fix --allow-dirty` |
| CI | `cargo fmt --check`, `cargo clippy --all-targets --all-features --locked -- -D warnings`, `cargo test --locked`, `cargo deny check` |
