# Resource Group

locals {
  network_name = "basic-network"
}


## Resource groups
resource "azurerm_resource_group" "hub" {
  name     = "rg-hub"
  location = var.location
}

## Network definition
resource "azurerm_virtual_network" "hub" {
  name                = "${local.network_name}-hub"
  address_space       = [var.hub_vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name

  subnet {
    name              = "snet-shared"
    address_prefixes  = ["10.0.0.0/24"]
  }
}

# Maybe add config for hub subnets for direct management in TF?

## Network peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each                  = var.spoke_vnets
  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spokes[each.key].id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false

  depends_on = [azurerm_virtual_network.spokes]
}
