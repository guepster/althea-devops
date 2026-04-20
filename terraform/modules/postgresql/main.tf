# PostgreSQL Flexible Server - HA zone-redundant, CMK HSM, pgaudit (HDS)
resource "azurerm_postgresql_flexible_server" "this" {
  name                = "psql-${var.env}-saas-fr-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "16"
  zone                = "1"
  sku_name            = var.sku_name
  storage_mb          = var.storage_mb

  high_availability { mode = "ZoneRedundant" }

  maintenance_window {
    day_of_week  = 0   # dimanche
    start_hour   = 2   # 02h UTC = 04h Paris
    start_minute = 0
  }

  tags = merge(var.tags, { DataClass = "HDS", Criticality = "critical", Backup = "yes" })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [zone, high_availability[0].standby_availability_zone]
  }
}

# Diagnostic settings - logs vers Wazuh / Log Analytics
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-psql-${var.env}-${var.app}"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  storage_account_id         = var.diag_storage_account_id
  log_analytics_workspace_id = var.law_workspace_id

  enabled_log { category = "PostgreSQLLogs" }
  enabled_log { category = "PostgreSQLFlexSessions" }
  enabled_log { category = "PostgreSQLFlexQueryStoreRuntime" }
  metric { category = "AllMetrics" }
}

# pgaudit - traçabilité HDS
resource "azurerm_postgresql_flexible_server_configuration" "pgaudit" {
  name      = "pgaudit.log"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "WRITE,DDL,ROLE"
}

resource "azurerm_postgresql_flexible_server_configuration" "shared_libs" {
  name      = "shared_preload_libraries"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "pgaudit,pg_stat_statements"
}
