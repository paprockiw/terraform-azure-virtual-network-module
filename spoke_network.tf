
resource "azurerm_resource_group" "spokes" {
  for_each = var.spoke_vnets
  name     = "rg-${each.key}"
  location = var.location
}

resource "azurerm_virtual_network" "spokes" {
  for_each            = var.spoke_vnets
  name                = "${local.network_name}-vnet-${each.key}"
  address_space       = [each.value]
  location            = var.location
  resource_group_name = azurerm_resource_group.spokes[each.key].name

  subnet {
    name              = "snet-workload"
    address_prefixes  = [cidrsubnet(each.value, 8, 0)]  # e.g., 10.1.0.0/24
  }

}

resource "azurerm_subnet" "spoke_subnets" {
  for_each             = var.spoke_vnets
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.spokes[each.key].name
  virtual_network_name = azurerm_virtual_network.spokes[each.key].name
  address_prefixes     = [cidrsubnet(each.value, 8, 0)]
}


resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                  = var.spoke_vnets
  name                      = "${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.spokes[each.key].name
  virtual_network_name      = azurerm_virtual_network.spokes[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false

  depends_on = [azurerm_virtual_network.hub]
}


# Routes
resource "azurerm_route_table" "spoke_rt" {
  for_each            = var.spoke_vnets
  name                = "rt-${each.key}-to-fw"
  location            = var.location
  resource_group_name = azurerm_resource_group.spokes[each.key].name
}

resource "azurerm_subnet_route_table_association" "spoke_rt_assoc" {
  for_each       = var.spoke_vnets
  subnet_id      = azurerm_subnet.spoke_subnets[each.key].id
  route_table_id = azurerm_route_table.spoke_rt[each.key].id
}

