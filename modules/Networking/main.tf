resource "azurerm_virtual_network" "vnets" {
  for_each            = var.vnets_subnets
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space

  dynamic "subnet" {
    for_each = contains(keys(each.value), "subnets") ? each.value.subnets : {}
    content {
      name           = subnet.key
      address_prefix = subnet.value.address_prefix
    }
  }
}

# resource "azurerm_subnet" "subnets" {
#   for_each = values({ for vnet_name, vnet_details in var.vnets_subnets : vnet_name =>
#     { for snetName, snetDetails in vnet_details.subnets : snetName => {
#       address_prefix = snetDetails.address_prefix
#       vnet_name      = vnet_name
#   } } })

#   name                 = each.key
#   resource_group_name  = var.vnets_subnets[each.value.vnet_name].resource_group_name
#   virtual_network_name = each.value.vnet_name
#   address_prefixes     = [each.value.address_prefix]
# }

output "vnet_subnet_ids" {
  value = {
    for vnet_name, vnet_data in azurerm_virtual_network.vnets :
    vnet_data.name => {
      for subnet in vnet_data.subnet :
      subnet.name => subnet.id
    }
  }
}

resource "azurerm_public_ip" "bastion-pip" {
  for_each            = { for k, v in var.vnets_subnets : k => v if v.enable_bastion == true }
  name                = "${each.key}-bastion-pip"
  location            = var.vnets_subnets[each.key].location
  resource_group_name = var.vnets_subnets[each.key].resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  snet_ids = {
    for vnet_name, vnet_data in azurerm_virtual_network.vnets :
    vnet_data.name => {
      for subnet in vnet_data.subnet :
      subnet.name => subnet.id
    }
  }
}

resource "azurerm_bastion_host" "bastion" {
  for_each = { for k, v in var.vnets_subnets : k => v if v.enable_bastion == true }

  name                = "${each.key}-bastion"
  location            = var.vnets_subnets[each.key].location
  resource_group_name = var.vnets_subnets[each.key].resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = local.snet_ids[each.key].AzureBastionSubnet
    public_ip_address_id = azurerm_public_ip.bastion-pip[each.key].id
  }
}
