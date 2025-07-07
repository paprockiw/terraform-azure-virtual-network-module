# Resource Group

locals {
  network_name = "basic-network-tf"
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${local.network_name}-rg"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "network" {
  name                = local.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

# Subnet
resource "azurerm_subnet" "subnet_1" {
  name                 = "subnet-1-${local.network_name}"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.subnet_cidr]
}

# Network Security Group
resource "azurerm_network_security_group" "sg_allow_public_ssh" {
  name                = "ssh-public-${local.network_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "sg_subnet_assoc" {
  subnet_id                 = azurerm_subnet.subnet_1.id
  network_security_group_id = azurerm_network_security_group.sg_allow_public_ssh.id
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-basic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
}

