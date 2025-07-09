
# Spoke networks
resource "azurerm_virtual_network" "spokes" {
  for_each = var.spoke_vnets

  name                = "${each.value.platform}-${each.value.environment}-vnet"
  address_space       = [each.value.address_space]
  location            = var.location
  resource_group_name = each.value.resource_group_name

}

# Subnets for each spoke network
resource "azurerm_subnet" "subnets" {
  for_each = {
    for item in flatten([
      for vnet_key, vnet in var.spoke_vnets : [
        for subnet in vnet.subnets : {
          subnet_key         = "${vnet_key}-${subnet.name}"
          subnet             = subnet
          vnet_key           = vnet_key
          address_space      = vnet.address_space
          rg_name            = vnet.resource_group_name
          vnet_name          = "${vnet.platform}-${vnet.environment}-vnet"
        }
      ]
    ]) : item.subnet_key => item
  }

  name                 = "snet-${each.value.subnet.name}"
  resource_group_name  = each.value.rg_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = [each.value.subnet.cidr]

  depends_on = [azurerm_virtual_network.spokes]
}


# Routes
resource "azurerm_route_table" "custom_routes" {
  for_each = azurerm_subnet.subnets

  name                = "${each.key}-rt"
  location            = var.location
  resource_group_name = each.value.resource_group_name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"  # Example: NVA
  }
}

resource "azurerm_subnet_route_table_association" "assoc" {
  for_each = azurerm_subnet.subnets

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.custom_routes[each.key].id
}

