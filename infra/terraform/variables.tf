variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "ecommerce-rg"
}

variable "location" {
  description = "Región de Azure donde se desplegarán los recursos"
  type        = string
  default     = "East US"
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry. Debe ser único globalmente."
  type        = string
  default     = "ecommerceacrios25" 
}

variable "aks_cluster_name" {
  description = "Nombre del clúster de AKS"
  type        = string
  default     = "ecommerce-aks"
}

variable "node_count" {
  description = "Número de nodos en el pool por defecto"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Tamaño de la VM para los nodos del clúster"
  type        = string
  default     = "Standard_B4ms"
}
