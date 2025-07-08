# Firewall
resource "azurerm_public_ip" "fw_ip" {
  name                = "fw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "fw-policy"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_firewall_policy_rule_collection_group" "allow_web" {
  name               = "allow-web"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100

  network_rule_collection {
    name     = "AllowWeb"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "AllowHTTPS"
      source_addresses      = ["10.1.0.0/24"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    }

    rule {
      name                  = "AllowHTTP"
      source_addresses      = ["10.1.0.0/24"]
      destination_addresses = ["*"]
      destination_ports     = ["80"]
      protocols             = ["TCP"]
    }
  }
}


resource "azurerm_firewall" "network_fw" {
  name                = "azfw-hub"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_ip.id
  }

  depends_on = [azurerm_firewall_policy.fw_policy]
}

