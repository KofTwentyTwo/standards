# Terraform / OpenTofu

Implements the [Terraform / OpenTofu profile](../../standards/coding/terraform.md).

| File | Copy to | Purpose |
| --- | --- | --- |
| [`.tflint.hcl`](.tflint.hcl) | repository root | TFLint with the `terraform` plugin's `all` preset, required versions and providers, documented variables and outputs, `snake_case` naming |

Layout is `tofu fmt` / `terraform fmt` (2 spaces), which is not configurable
(K22-CODE-TF-02).

## Use

```bash
tofu fmt -recursive                  # layout (terraform fmt works the same)
tofu init -backend=false && tofu validate
tflint --init && tflint --recursive
trivy config .                       # misconfiguration scan
```

## IDEs

- **VS Code:** HashiCorp Terraform extension, format on save; see [`../vscode`](../vscode).
- **JetBrains:** Terraform and HCL plugin; *Settings → Tools → Terraform and OpenTofu* →
  enable `fmt` on save and TFLint.

## Verified

Written against the TFLint configuration schema; not run here.
