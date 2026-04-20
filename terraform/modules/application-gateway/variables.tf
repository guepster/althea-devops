variable "env"                 { type = string }
variable "site"                { type = string  default = "fr" }
variable "idx"                 { type = string  default = "01" }
variable "resource_group_name" { type = string }
variable "location"            { type = string  default = "francecentral" }
variable "tags"                { type = map(string)  default = {} }
