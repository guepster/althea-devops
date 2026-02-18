# PostgreSQL Flexible Server — HA zone-redundant, CMK HSM (HDS)
resource "azurerm_postgresql_flexible_server" "this" {
  name                = "psql-${var.env}-saas-fr-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "16"
  zone                = "1"
  high_availability { mode = "ZoneRedundant" }
  storage_mb          = var.storage_mb
  sku_name            = var.sku_name
  tags                = var.tags
}
