terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Configuración del backend para guardar el estado remotamente.
  # Estos valores deben ser suministrados al inicializar terraform (terraform init)
  # o mediante un archivo de configuración parcial.
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate2025ios" 
    container_name       = "tfstate" 
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Grupo de Recursos
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
# SKU Basic para bajo costo, admin_enabled true como solicitado.
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  # Configuración Low-Cost solicitada
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size # Standard_B4ms (4 vCPU, 16GB RAM)
  }

  # Identidad gestionada por el sistema
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
    Project     = "Ecommerce-Microservices"
  }
}

# Asignación de roles para permitir que AKS descargue imágenes del ACR
# Se asigna el rol 'AcrPull' a la identidad 'kubelet' del clúster sobre el ACR.
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
