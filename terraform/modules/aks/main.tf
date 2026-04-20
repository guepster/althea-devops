# Module AKS - cluster SaaS médical (zone-redundant, CMK HSM, RBAC Entra ID)
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
    os_disk_type                 = "Managed"
    os_disk_size_gb              = 128
    type                         = "VirtualMachineScaleSets"
    vnet_subnet_id               = var.aks_subnet_id
    upgrade_settings { max_surge = "33%" }
  }

  # Réseau Azure CNI Overlay + Calico NetworkPolicy
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.100.0/24"
    dns_service_ip      = "10.0.100.10"
    load_balancer_sku   = "standard"
    outbound_type       = "userAssignedNATGateway"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = [var.aks_admin_group_id]
    tenant_id              = var.tenant_id
  }

  disk_encryption_set_id = var.disk_encryption_set_id # CMK HSM (HDS)

  oms_agent {
    log_analytics_workspace_id      = var.law_workspace_id
    msi_auth_for_monitoring_enabled = true
  }
  microsoft_defender { log_analytics_workspace_id = var.law_workspace_id }

  azure_policy_enabled      = true
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  api_server_access_profile { authorized_ip_ranges = var.api_authorized_ip_ranges }

  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "least-waste"
    scale_down_delay_after_add       = "10m"
    scale_down_unneeded              = "10m"
    scale_down_utilization_threshold = 0.5
    max_graceful_termination_sec     = 600
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count, kubernetes_version]
  }
}

# Node pool applicatif - workload SaaS médical (autoscaling 3..15)
resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_D8s_v5"
  node_count            = 3
  enable_auto_scaling   = true
  min_count             = 3
  max_count             = 15
  zones                 = ["1", "2", "3"]
  os_disk_type          = "Managed"
  os_disk_size_gb       = 256
  vnet_subnet_id        = var.aks_subnet_id
  node_labels           = { workload = "saas", dataclass = "hds" }
  upgrade_settings { max_surge = "33%" }
  tags                  = var.tags
}
