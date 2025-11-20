output "resource_group_name" {
  description = "El nombre del grupo de recursos creado"
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "El servidor de inicio de sesión del ACR (usar para docker login/tag)"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuario administrador del ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Contraseña administrador del ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "aks_cluster_name" {
  description = "El nombre del clúster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "Configuración de Kubernetes (kubeconfig) para conectar con kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "get_credentials_command" {
  description = "Comando para obtener las credenciales del clúster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}
