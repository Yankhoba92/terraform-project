variable "location" {
  description = "Région Azure"
  default     = "East US"
}

variable "admin_username" {
  description = "Nom d'utilisateur administrateur de la VM"
  default     = "adminuser"
}
variable "storage_account_name_yankhoba" {
  description = "Nom du compte de stockage"
  default     = "mystorageaccountyankhoba"
}

variable "blob_container_name" {
  description = "Nom du conteneur Blob"
  default     = "staticfiles"
}
