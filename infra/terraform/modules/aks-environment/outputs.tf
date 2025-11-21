output "rg_name" {
  description = "Nombre del Resource Group creado"
  value       = azurerm_resource_group.rg.name
}

output "aks_name" {
  description = "Nombre del clúster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  description = "Servidor de login del ACR"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_password" {
  description = "Password de administrador del ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
