module "keyvault" {
  source              = "../../modules/keyvault"
  env                 = "prod"
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
}

module "postgresql" {
  source              = "../../modules/postgresql"
  env                 = "prod"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

module "aks" {
  source                 = "../../modules/aks"
  env                    = "prod"
  resource_group_name    = var.resource_group_name
  aks_subnet_id          = var.aks_subnet_id
  aks_admin_group_id     = var.aks_admin_group_id
  tenant_id              = var.tenant_id
  disk_encryption_set_id = var.disk_encryption_set_id
  tags                   = var.tags
}
