variable "env"                     { type = string }
variable "app"                     { type = string  default = "saas" }
variable "resource_group_name"     { type = string }
variable "location"                { type = string  default = "francecentral" }
variable "storage_mb"              { type = number  default = 131072 }
variable "sku_name"                { type = string  default = "GP_Standard_D4s_v5" }
variable "diag_storage_account_id" { type = string  default = null }
variable "law_workspace_id"        { type = string  default = null }
variable "tags"                    { type = map(string)  default = {} }
