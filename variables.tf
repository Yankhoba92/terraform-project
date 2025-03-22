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

variable "admin_password" {
  description = "Mot de passe administrateur pour la VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Clé publique SSH pour la VM"
  type        = string
}

variable "admin_ssh_key" {
  description = "Path to the public SSH key to be used for the VM"
  type        = string
}

variable "mysql_admin_password" {
  description = "The password for the MySQL administrator"
  type        = string
  sensitive   = true
}

variable "admin_ssh_private_key" {
  description = "The path to the private SSH key to access the VM"
  type        = string
}