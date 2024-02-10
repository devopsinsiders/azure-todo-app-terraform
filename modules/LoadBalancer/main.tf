resource "azurerm_public_ip" "pip" {
  for_each            = var.loadbalancers
  name                = "${each.key}-lb-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = each.value.sku
}

resource "azurerm_lb" "lb" {
  for_each = var.loadbalancers

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  frontend_ip_configuration {
    name                 = each.value.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  for_each = var.backend_pools

  loadbalancer_id = azurerm_lb.lb[each.value.lb_name].id
  name            = each.key
}

resource "azurerm_network_interface_backend_address_pool_association" "bapa" {
  for_each                = transpose({ for k, v in var.backend_pools : k => v.backend_vms })
  network_interface_id    = var.nic_ids[each.key]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool[each.value[0]].id
}

resource "azurerm_lb_probe" "probe" {
  for_each        = var.backend_pools
  loadbalancer_id = azurerm_lb.lb[each.value.lb_name].id
  name            = "${each.key}-probe"
  port            = each.value.port
}

resource "azurerm_lb_rule" "rule" {
  for_each                       = var.backend_pools
  loadbalancer_id                = azurerm_lb.lb[each.value.lb_name].id
  name                           = "${each.key}-rule"
  protocol                       = "Tcp"
  frontend_port                  = each.value.port
  backend_port                   = each.value.port
  frontend_ip_configuration_name = var.loadbalancers[each.value.lb_name].frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool[each.key].id]
  probe_id                       = azurerm_lb_probe.probe[each.key].id
}
