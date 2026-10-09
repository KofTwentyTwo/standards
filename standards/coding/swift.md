# Swift profile

The [Kingsrook coding standard](README.md) applied to Swift. Requirement IDs are
`K22-CODE-SW-NN`. Configuration: [`configs/swift/`](../../configs/swift).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| Toolchain | Xcode / Swift 6.x | Swift 6 language mode; Xcode version pinned in CI |
| Formatter | Apple [swift-format](https://github.com/swiftlang/swift-format) (ships with the Swift toolchain) | toolchain version |
| Linter | [SwiftLint](https://github.com/realm/SwiftLint) `--strict` | pinned (Mint, Homebrew bundle, or build-tool plugin) |
| Tests | Swift Testing (`@Test`), XCTest for UI tests | toolchain |
| Coverage | `xcodebuild -enableCodeCoverage YES` / `swift test --enable-code-coverage` | |

## Requirements

**K22-CODE-SW-01 (MUST)** `swift-format lint --strict` passes with the KofTwentyTwo
[`.swift-format`](../../configs/swift/.swift-format): **3-space indentation**, at most
one blank line, no practical line limit, `else`/`catch` on new lines
(`lineBreakBeforeControlFlowKeywords`).
*Verified by:* swift-format in CI.

**K22-CODE-SW-02 (MUST)** Deviation: opening braces stay on the same line, and control
keywords keep their space (`if ready {`). Neither swift-format nor SwiftLint can produce
or enforce next-line braces, and Swift's grammar has no parentheses around conditions.
Members are separated by one blank line because swift-format caps blank lines globally.
Every non-layout Kingsrook rule still applies.

**K22-CODE-SW-03 (MUST)** `swiftlint --strict` passes with
[`.swiftlint.yml`](../../configs/swift/.swiftlint.yml): no force unwraps or force tries,
documented public declarations, sorted imports, tracked TODOs, and no
`print`/`debugPrint`/`NSLog` (use `os.Logger` with privacy-annotated interpolation).
*Verified by:* SwiftLint in CI.

**K22-CODE-SW-04 (MUST)** Swift 6 language mode with complete strict concurrency
checking; warnings as errors (`SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`).
*Verified by:* the build settings.

**K22-CODE-SW-05 (MUST)** Header comments (K22-CODE-09) are `///` documentation comments,
because Xcode Quick Help and DocC read only those. Explanatory comments inside bodies use
the flower-box shape.

## Commands

| Where | Command |
| --- | --- |
| Local fix | `swift format --in-place --recursive Sources Tests` and `swiftlint --fix` |
| CI | `swift format lint --strict --recursive Sources Tests`, `swiftlint --strict`, `swift test` / `xcodebuild test` |
