variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "hub_vnet_details" {
  type = object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      name             = string
      address_prefixes = list(string)
      nsg_name         = string
      security_rules = list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      }))
      delegation_name             = optional(string, "")
      service_delegation_name     = optional(string, "")
      service_delegation_action   = optional(list(string), [])
      associated_route_table_name = string
    }))
  })
  description = <<DESCRIPTION
(Required) Object hub vnet details, then an nested map for subnet creation with NSGs. Assumption is that each Hub subnet will have its own NSG.

- `name` - The name of the Spoke Vnet
- `address_space` - The CIDR block of the Spoke Vnet address space that encompasses the hub subnets.

subnets - The nested map(object) (optional)
 - `name` - (Required) The name of the subnet.
 - `address_prefixes` - (Required) The address prefixes to use for the subnet.
 - `nsg_name` - (Required) The name of the Network Security Group (NSG) for the subnet, dynamically constructed. 
 - `security_rules` - (Optional) The inputs for the Network Security Group Rule creation:
     - name, priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix
    - ["ssh", "200", "Inbound", "Allow", "Tcp", "22", "10.88.4.4", "*"]
    - See .tfvars for actual rule creation inputs.
 - `delegation_name` -  The name for delegation. optional(string, "")
 - `service_delegation_name` - The name of the service to which the subnet is delegated. optional(string, "")
 - `service_delegation_action` - Actions allowed for the service delegation. optional(list(string), [])   

  DESCRIPTION
}

variable "route_tables" {
  description = "Map of route tables to create"
  type        = map(any)
}

variable "routes" {
  description = "Map of routes to create"
  type = map(object({
    address_prefix   = string
    next_hop_type    = string
    route_table_name = string
  }))
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
