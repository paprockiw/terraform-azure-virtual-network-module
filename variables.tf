variable "location" {
  default = "East US"
}

variable "hub_vnet_cidr" {
  default = "10.0.0.0/16"
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

  default = {
    dev = {
      environment         = "dev"
      platform            = "web"
      address_space       = "10.10.0.0/16"
      resource_group_name = "dev-terraform-test"
      subnets = [
        { name = "workload", cidr = "10.10.1.0/24" },
        { name = "database", cidr = "10.10.2.0/24" }
      ]
    }
    prod = {
      environment         = "prod"
      platform            = "api"
      address_space       = "10.20.0.0/16"
      resource_group_name = "prod-terraform-test"
      subnets = [
        { name = "app", cidr = "10.20.1.0/24" },
        { name = "db", cidr = "10.20.2.0/24" },
        { name = "bastion", cidr = "10.20.3.0/24" }
      ]
    }
  }

}
