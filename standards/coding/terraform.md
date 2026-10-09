# Terraform / OpenTofu profile

The [Kingsrook coding standard](README.md) applied to HCL infrastructure code.
Requirement IDs are `K22-CODE-TF-NN`. Configuration:
[`configs/terraform/`](../../configs/terraform).

## Tooling

| Concern | Tool | Version policy |
| --- | --- | --- |
| Engine | OpenTofu (preferred) or Terraform | `required_version` pinned; `.terraform.lock.hcl` committed |
| Formatter | `tofu fmt` / `terraform fmt` | engine version |
| Linter | [TFLint](https://github.com/terraform-linters/tflint) with [`.tflint.hcl`](../../configs/terraform/.tflint.hcl) | pinned |
| Misconfiguration scan | Trivy (`trivy config`) | pinned image digest |
| Docs | terraform-docs (module READMEs) | pinned |

## Requirements

**K22-CODE-TF-01 (MUST)** `tofu fmt -check -recursive` and `tofu validate` pass.
*Verified by:* CI.

**K22-CODE-TF-02 (MUST)** Deviation: layout is exactly `fmt`'s (2-space indentation,
aligned `=`, same-line braces). The formatter is not configurable and is the universal
convention for HCL. Every non-layout Kingsrook rule still applies: descriptive
`snake_case` names, a `description` on every variable and output (the HCL form of the
header comment), no commented-out resources.

**K22-CODE-TF-03 (MUST)** TFLint passes with the `terraform` plugin's `all` preset and
documented variables and outputs; `trivy config` reports no HIGH or CRITICAL
misconfiguration.
*Verified by:* CI.

**K22-CODE-TF-04 (MUST)** State is never committed: remote state with locking and
encryption, `*.tfstate*` in `.gitignore`. Providers and modules are pinned to exact
versions, and the dependency lock file is committed.
*Verified by:* gitleaks / `.gitignore`; review. *Maps to:* OSPS-BR-07.01, OSPS-QA-02.01.

**K22-CODE-TF-05 (MUST)** No secrets in variables' defaults, `.tfvars` files, or
outputs; sensitive values are marked `sensitive = true` and come from a secret store or
CI OIDC credentials.
*Verified by:* Trivy secret scanning, TFLint; review.

## Commands

| Where | Command |
| --- | --- |
| Local fix | `tofu fmt -recursive` |
| CI | `tofu fmt -check -recursive`, `tofu init -backend=false && tofu validate`, `tflint --init && tflint --recursive`, `trivy config .` |
