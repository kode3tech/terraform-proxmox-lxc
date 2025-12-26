plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# Disable unused declarations check in examples
# Variables are declared for documentation purposes in Terraform Registry
rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = true
}
