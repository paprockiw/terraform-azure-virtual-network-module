variable "location" {
  default = "East US"
}

variable "hub_vnet_cidr" {
  default = "10.0.0.0/16"
}

variable "spoke_vnets" {
  description = "List of spoke VNets and CIDRs"
  default = {
    spoke1 = "10.1.0.0/16"
    spoke2 = "10.2.0.0/16"
  }
}

