terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod"
    storage_account_name = "sttfstateprod01"
    container_name       = "prod"
    key                  = "althea-prod.tfstate"
  }
}
