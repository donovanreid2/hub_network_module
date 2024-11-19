#---------------------------------------
# Outputs for Resource Group
#---------------------------------------

output "resource_group_name" {
  value = local.resource_group_name
}

output "resource_group_location" {
  value = local.location
}

#---------------------------------------
# Outputs for Virtual Network
#---------------------------------------

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "virtual_network_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

#---------------------------------------
# Outputs for Subnets
#---------------------------------------

output "subnet_ids" {
  value = { for k, v in azurerm_subnet.snet : k => v.id }
}

output "subnet_names" {
  value = { for k, v in azurerm_subnet.snet : k => v.name }
}

#---------------------------------------
# Outputs for Network Security Groups
#---------------------------------------

output "nsg_ids" {
  value = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "nsg_names" {
  value = { for k, v in azurerm_network_security_group.nsg : k => v.name }
}

#---------------------------------------
# Outputs for Route Tables
#---------------------------------------

output "route_table_ids" {
  value = { for k, v in azurerm_route_table.rt : k => v.id }
}

output "route_table_names" {
  value = { for k, v in azurerm_route_table.rt : k => v.name }
}

#---------------------------------------
# Outputs for Routes
#---------------------------------------

output "route_ids" {
  value = { for k, v in azurerm_route.route : k => v.id }
}

output "route_names" {
  value = { for k, v in azurerm_route.route : k => v.name }
}
