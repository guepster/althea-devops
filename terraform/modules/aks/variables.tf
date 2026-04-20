variable "env"                      { type = string }
variable "site"                     { type = string  default = "fr" }
variable "idx"                      { type = string  default = "01" }
variable "location"                 { type = string  default = "francecentral" }
variable "resource_group_name"      { type = string }
variable "k8s_version"              { type = string  default = "1.29" }
variable "sku_tier"                 { type = string  default = "Standard" }
variable "aks_subnet_id"            { type = string }
variable "aks_admin_group_id"       { type = string }
variable "tenant_id"                { type = string }
variable "disk_encryption_set_id"   { type = string }
variable "law_workspace_id"         { type = string  default = null }
variable "api_authorized_ip_ranges" { type = list(string)  default = [] }
variable "tags"                     { type = map(string)  default = {} }
