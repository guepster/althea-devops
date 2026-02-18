# Key Vault Standard (secrets runtime) + Key Vault HSM (clés CMK)
resource "azurerm_key_vault" "standard" {
  name                = "alt-${var.env}-kv-fr-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  rbac_authorization_enabled = true
}

resource "azurerm_key_vault" "hsm" {
  name                = "alt-${var.env}-kv-fr-hsm-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "premium"   # HSM-backed (FIPS 140-2)
  rbac_authorization_enabled = true
}
