# Backend Azure Storage - PROD (state distant, versioning + lock natif)
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-alt-tfstate-prod"
    storage_account_name = "stalttfstateprod"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"

    use_oidc         = true   # auth OIDC via GitLab (pas de credentials)
    use_azuread_auth = true   # MS Entra ID (pas de clé d'accès Storage)
  }
}
