resource "azurerm_mssql_server" "servers" {
  for_each                     = var.servers_dbs
  name                         = each.key
  resource_group_name          = each.value.resource_group_name
  location                     = each.value.location
  version                      = each.value.version
  administrator_login          = each.value.administrator_login
  administrator_login_password = each.value.administrator_login_password
}

resource "azurerm_mssql_database" "dbs" {
  for_each  = transpose({ for k, v in var.servers_dbs : k => v.dbs })
  name      = each.key
  server_id = azurerm_mssql_server.servers[each.value[0]].id
}

output "db_connection_strings" {
  value = transpose({ for k, v in var.servers_dbs : k => v.dbs })
}