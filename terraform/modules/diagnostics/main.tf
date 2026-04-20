# Diagnostic Settings standardisés - export logs Azure vers SIEM (cf. DAT B.5)
# 1) Storage WORM (archivage 5 ans HDS)  2) Log Analytics  3) Event Hub -> Wazuh

resource "azurerm_storage_account" "logs_archive" {
  name                     = "stalt${var.env}logsarc${var.site}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Cool"

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    delete_retention_policy { days = 90 }
    container_delete_retention_policy { days = 90 }
  }

  immutability_policy {
    allow_protected_append_writes = true
    state                         = "Locked"             # WORM
    period_since_creation_in_days = 1825                 # 5 ans (HDS art. 7.1)
  }

  identity { type = "SystemAssigned" }
  customer_managed_key {
    key_vault_key_id          = var.cmk_key_id
    user_assigned_identity_id = var.cmk_identity_id
  }
  tags = merge(var.tags, { DataClass = "hds", Purpose = "logs-archive" })
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.env}-althea-${var.site}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 365
  daily_quota_gb      = var.law_daily_quota_gb
  tags                = var.tags
}

resource "azurerm_eventhub_namespace" "siem" {
  name                     = "evhns-${var.env}-althea-siem-${var.site}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = "Standard"
  capacity                 = 2
  auto_inflate_enabled     = true
  maximum_throughput_units = 10
  tags                     = var.tags
}

resource "azurerm_eventhub" "wazuh_feed" {
  name                = "azure-events-to-wazuh"
  namespace_name      = azurerm_eventhub_namespace.siem.name
  resource_group_name = var.resource_group_name
  partition_count     = 4
  message_retention   = 7
}

# Application sur toutes les VMs du projet
resource "azurerm_monitor_diagnostic_setting" "vm" {
  for_each                       = toset(var.vm_ids)
  name                           = "diag-vm-${each.key}"
  target_resource_id             = each.value
  storage_account_id             = azurerm_storage_account.logs_archive.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  eventhub_authorization_rule_id = var.wazuh_eventhub_auth_rule_id
  eventhub_name                  = azurerm_eventhub.wazuh_feed.name
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
