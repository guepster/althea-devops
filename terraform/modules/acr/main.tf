# Azure Container Registry durci CIS Azure / HDS (cf. DAT 4.4.4)
resource "azurerm_container_registry" "this" {
  name                          = "acr${var.env}altheafr01"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"        # requis : geo-rep + private endpoint
  admin_enabled                 = false            # Entra ID uniquement, pas de mot de passe local
  public_network_access_enabled = false            # exposé via Private Endpoint uniquement
  data_endpoint_enabled         = true
  trust_policy { enabled = true }                  # Content Trust : images signées seulement

  georeplications {
    location                = "switzerlandnorth"   # PRA : FR Centre -> Suisse Nord
    zone_redundancy_enabled = true
  }

  retention_policy {
    days    = 30                                   # images sans tag purgées à 30j
    enabled = true
  }

  tags = merge(var.tags, { DataClass = "hds" })
}
