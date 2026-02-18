# Module AKS — cluster SaaS médical (zone-redundant, CMK HSM, RBAC Entra ID)
resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.env}-saas-${var.site}-${var.idx}"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "aks-${var.env}-saas"
  kubernetes_version  = var.k8s_version
  sku_tier            = var.sku_tier

  identity { type = "SystemAssigned" }

  default_node_pool {
    name                         = "system"
    vm_size                      = "Standard_D4s_v5"
    node_count                   = 3
    zones                        = ["1", "2", "3"]
    only_critical_addons_enabled = true
    type                         = "VirtualMachineScaleSets"
    vnet_subnet_id               = var.aks_subnet_id
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    load_balancer_sku   = "standard"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = [var.aks_admin_group_id]
    tenant_id              = var.tenant_id
  }

  # Chiffrement disque CMK HSM (exigence HDS)
  disk_encryption_set_id    = var.disk_encryption_set_id
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  azure_policy_enabled      = true

  tags = var.tags
}

# Node pool applicatif — autoscaling 3..15
resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_D8s_v5"
  enable_auto_scaling   = true
  min_count             = 3
  max_count             = 15
  zones                 = ["1", "2", "3"]
  node_labels           = { workload = "saas", dataclass = "hds" }
  tags                  = var.tags
}
