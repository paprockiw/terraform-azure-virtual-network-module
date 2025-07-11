variable "location" {
  type = string
  description = "Azure location for network"
}

variable "hub_vnet_cidr" {
  type = string
  description = "CIDR block for hub network"
}

variable "spoke_vnets" {
  description = "Map of spoke VNets with multiple subnets and associated metadata"
  type = map(object({
    environment         = string
    platform            = string
    address_space       = string
    resource_group_name = string
    subnets             = list(object({
      name = string
      cidr = string
    }))
  }))
}
