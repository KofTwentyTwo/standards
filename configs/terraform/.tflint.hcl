# KofTwentyTwo TFLint configuration (K22-CODE-TF). CI runs `tflint --init && tflint
# --recursive --format compact`. Layout is `tofu fmt` / `terraform fmt` (2 spaces, not
# configurable), so Kingsrook layout does not apply to HCL (K22-CODE-TF-02).
config {
  call_module_type = "local"
  force            = false
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
