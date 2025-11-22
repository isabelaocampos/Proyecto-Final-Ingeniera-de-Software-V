terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Tu backend remoto se queda IGUAL (No lo borres)
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

# --- CONFIGURACIÓN POR AMBIENTE ---
locals {
  env = terraform.workspace # Obtiene "dev", "stage" o "prod"

  # Mapa de configuración: Define las reglas del juego
  env_settings = {
    default = { node_count = 1, vm_size = "Standard_B2ms" } 
    
    dev = {
      node_count = 1
      vm_size    = "Standard_B2ms" # Barato
    }
    
    stage = {
      node_count = 1
      vm_size    = "Standard_B4ms" # Igual a dev
    }
    
    prod = {
      node_count = 2               # ¡Más potencia para prod!
      vm_size    = "Standard_B4ms" # (O podrías usar D2s_v3 si tuvieras crédito)
    }
  }

  # Selecciona la configuración según el workspace actual
  selected_conf = lookup(local.env_settings, local.env, local.env_settings["default"])
}

# --- LLAMADA AL MÓDULO ---
module "aks_stack" {
  source = "./modules/aks-environment"

  location      = "Canada Central"

  # Pasamos los valores dinámicos
  env_name      = local.env
  node_count    = local.selected_conf.node_count
  vm_size       = local.selected_conf.vm_size
  
  
  acr_base_name = "ecommerceacrios25" 
}

# --- OUTPUTS FINALES ---
output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${module.aks_stack.rg_name} --name ${module.aks_stack.aks_name}"
}

output "acr_password" {
  value     = module.aks_stack.acr_admin_password
  sensitive = true
}

output "acr_login_server" {
  value = module.aks_stack.acr_login_server
}