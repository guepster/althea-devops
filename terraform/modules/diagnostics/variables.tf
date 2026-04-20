variable "env"                        { type = string }
variable "site"                       { type = string  default = "fr" }
variable "resource_group_name"        { type = string }
variable "location"                   { type = string  default = "francecentral" }
variable "cmk_key_id"                 { type = string }
variable "cmk_identity_id"            { type = string }
variable "law_daily_quota_gb"         { type = number  default = 15 }
variable "vm_ids"                     { type = list(string)  default = [] }
variable "wazuh_eventhub_auth_rule_id"{ type = string  default = null }
variable "tags"                       { type = map(string)  default = {} }
