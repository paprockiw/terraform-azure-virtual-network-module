# terraform-azure-virtual-network-module
A basic virtual network configuration for Azure.

NOTE: this is still a work in progress and hasn't seen usage yet.


# Azure Hub-and-Spoke Network Infrastructure
This Terraform configuration provisions a secure and extensible 
**hub-and-spoke network topology** in Microsoft Azure. 
It includes **virtual networks, subnets, routing, network peering, and a centralized Azure Firewall**.

---

## Table of Contents

1. [Overview](#overview)  
2. [Architecture](#architecture)  
3. [Resources Created](#resources-created)  
4. [Variable Inputs](#variable-inputs)  
5. [Requirements](#requirements)  
6. [Usage](#usage)  
7. [Peering Behavior](#peering-behavior)  
8. [Firewall Configuration](#firewall-configuration)  
9. [Extending the Network](#extending-the-network)  

---

## Overview

This module builds a complete hub-and-spoke virtual network configuration using 
Terraform and the AzureRM provider. The hub network includes a centralized 
firewall with policy-based rules. Each spoke VNet is defined with its own 
subnets and route table associations, and peered back to the hub.

---

## Architecture
```
┌────────────┐        ┌────────────┐
│ Spoke VNet │◀──────▶│  Hub VNet  │◀─────▶ Azure Firewall
└────────────┘        └────────────┘
     ▲
     │
┌────────────┐
│ Spoke VNet │
└────────────┘

```
- **Hub VNet**: Centralized network containing the Azure Firewall and shared services.
- **Spoke VNets**: Application-specific networks (e.g., dev, prod) with custom subnets.
- **Firewall**: Deployed in the hub, with outbound rules for HTTP/S.
- **Peering**: Bidirectional connectivity between each spoke and the hub.

---

## Resources Created

- Azure Resource Groups (per VNet)
- Virtual Networks (hub + dynamic spokes)
- Subnets (per spoke definition)
- Azure VNet Peerings (hub ↔ each spoke)
- Azure Firewall and Public IP
- Route Tables with default routes to firewall
- Firewall Policy with HTTP/HTTPS allow rules

---

## Variable Inputs

| Name              | Type          | Description                                    | Default         |
|-------------------|---------------|------------------------------------------------|-----------------|
| `location`        | `string`      | Azure region for all resources                 | `"East US"`     |
| `hub_vnet_cidr`   | `string`      | Address space for the hub virtual network      | `"10.0.0.0/16"` |
| `spoke_vnets`     | `map(object)` | Map of spoke VNets, w/ metadata, subnets, rgs  | See below       |

### Example `spoke_vnets` Input:

```hcl
spoke_vnets = {
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
```

## Requirements
 - Terraform 1.3+
 - Azure CLI (az login)
 - AzureRM provider (hashicorp/azurerm)
 - Subscription ID (be sure to configure AZ provider with this)

## Usage 
Run the following to build this:
```
az login
terraform init
terraform apply

```


## Peering Behavior
Each spoke is peered to the hub, and the hub is peered back to each spoke, allowing:
 - Full VNet-to-VNet communication
 - Centralized inspection and control via Azure Firewall
 - Optional route propagation for transitive routing


## Firewall Configuration
The firewall uses a policy-based rule collection:

 - Allows outbound HTTP (80) and HTTPS (443) from a specific subnet range (10.1.0.0/24)
 - Uses a static Public IP
 - Managed via azurerm_firewall_policy and azurerm_firewall_policy_rule_collection_group
 - Important: Update source_addresses in the firewall rules as needed for your spoke subnets.


## Extending the Network
You can:

- Add more spoke VNets by extending the spoke_vnets map
- Attach route tables, NSGs, or private endpoints
- Expand firewall rules by adding more rule block


