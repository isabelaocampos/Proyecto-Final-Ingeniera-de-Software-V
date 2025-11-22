variable "env_name" {
  description = "Nombre del ambiente (ej: dev, stage, prod) para sufijar recursos"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "Canada Central"
}

variable "node_count" {
  description = "Número de nodos en el pool por defecto"
  type        = number
}

variable "vm_size" {
  description = "Tamaño de la VM para los nodos"
  type        = string
  default     = "Standard_B4ms"
}

variable "acr_base_name" {
  description = "Nombre base para el Azure Container Registry"
  type        = string
}
