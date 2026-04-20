variable "env"                 { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string  default = "francecentral" }
variable "tags"                { type = map(string)  default = {} }
