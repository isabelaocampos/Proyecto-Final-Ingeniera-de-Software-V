resource "azurerm_resource_group" "rg" {
  name     = "ecommerce-rg-${var.env_name}"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.acr_base_name}${var.env_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "ecommerce-aks-${var.env_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ecommerce-aks-${var.env_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.env_name
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "mysql-${var.env_name}-${var.acr_base_name}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "adminuser"
  administrator_password = "SecurePassword123!"
  sku_name               = "B_Standard_B1ms"
  version                = "5.7"

  zone                   = "2"  
   
  storage {
    size_gb = 20
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_database" "ecommerce_db" {
  name                = "ecommerce_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}