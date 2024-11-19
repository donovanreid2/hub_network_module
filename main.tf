# Note: DDOS protection, Network Watcher and Fiewall subnet resources have been commmented out
# as they are managed thru Azure Policy. 

provider "azurerm" {
  features {}
}


#-----------------------
# Local declarations
#-----------------------

locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp[*].name, azurerm_resource_group.rg[*].name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp[*].location, azurerm_resource_group.rg[*].location, [""]), 0)
}

#---------------------------------------
# Resource Group Creation or selection
#---------------------------------------

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

#-----------------------
# VNET Creation
#-----------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.hub_vnet_details.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = var.hub_vnet_details.address_space
  tags                = merge({ "ResourceName" = format("%s", var.hub_vnet_details.name) }, var.tags)
}

resource "azurerm_subnet" "snet" {
  for_each             = var.hub_vnet_details.subnets
  name                 = each.value.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation_name != "" && each.value.service_delegation_name != "" && length(each.value.service_delegation_action) > 0 ? [each.value] : []
    content {
      name = delegation.value.delegation_name
      service_delegation {
        name    = delegation.value.service_delegation_name
        actions = delegation.value.service_delegation_action
      }
    }
  }
}

#-----------------------------------------------
# Network security group 
#-----------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.hub_vnet_details.subnets
  name                = each.value.nsg_name
  resource_group_name = local.resource_group_name
  location            = local.location
  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
  tags = merge({ "ResourceName" = format("%s", each.value.nsg_name) }, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = { for k, v in var.hub_vnet_details.subnets : k => v if v.name != "GatewaySubnet" }
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

#-----------------------------------------------
# Route and Route Tables
#-----------------------------------------------

resource "azurerm_route_table" "rt" {
  for_each            = var.route_tables
  name                = each.key
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_subnet_route_table_association" "rt-assoc" {
  for_each       = var.hub_vnet_details.subnets
  subnet_id      = azurerm_subnet.snet[each.key].id
  route_table_id = azurerm_route_table.rt[each.value.associated_route_table_name].id
}

resource "azurerm_route" "route" {
  for_each            = var.routes
  name                = each.key
  resource_group_name = local.resource_group_name
  address_prefix      = each.value.address_prefix
  next_hop_type       = each.value.next_hop_type
  route_table_name    = azurerm_route_table.rt[each.value.route_table_name].name
}
