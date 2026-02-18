variable "resource_group_name"    { type = string }
variable "tenant_id"              { type = string }
variable "aks_subnet_id"          { type = string }
variable "aks_admin_group_id"     { type = string }
variable "disk_encryption_set_id" { type = string }
variable "tags"                   { type = map(string)  default = { project = "althea", env = "prod" } }
