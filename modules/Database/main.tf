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

resource "azurerm_mssql_firewall_rule" "allow_access_to_azure_services" {
  for_each = { for db_server_name, db_server_details in var.servers_dbs : db_server_name => db_server_details if db_server_details.allow_access_to_azure_services == true }

  name             = "allow_access_to_azure_services"
  server_id        = azurerm_mssql_server.servers[each.key].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "db_connection_strings" {
  value = { for k, v in transpose({ for key, value in var.servers_dbs : key => value.dbs }) : k => "Driver={ODBC Driver 17 for SQL Server};Server=tcp:${v[0]}.database.windows.net,1433;Database=${k};Uid=${var.servers_dbs[v[0]].administrator_login};Pwd=${var.servers_dbs[v[0]].administrator_login_password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;" }
}
