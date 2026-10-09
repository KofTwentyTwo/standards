# Swift

Implements the [Swift profile](../../standards/coding/swift.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`.swift-format`](.swift-format) | repository root | Apple swift-format: 3-space indent, one blank line maximum, `else`/`catch` on new lines, documentation and safety rules |
| [`.swiftlint.yml`](.swiftlint.yml) | repository root | SwiftLint: safety and documentation rules, banned `print`/`NSLog`, layout rules that would fight swift-format disabled |

Braces stay on the same line in Swift (K22-CODE-SW-02).

## Use

```bash
swift format --in-place --recursive Sources Tests
swift format lint --strict --recursive Sources Tests
swiftlint --strict
```

## IDEs

- **Xcode:** add a *Run Script* build phase (or the SwiftLint build-tool plugin) that
  runs `swiftlint`; use *Editor → Structure → Format File with swift-format* (Xcode 16+)
  or an `swift format` pre-commit hook. Set *Settings → Text Editing → Indentation* to
  3 spaces.
- **VS Code:** the Swift extension formats with swift-format; see [`../vscode`](../vscode).

## Verified

Written against the swift-format and SwiftLint configuration schemas; not run here (no
Swift toolchain on this Windows machine). Validate on macOS before the first adoption.
