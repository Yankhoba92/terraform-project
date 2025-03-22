output "vm_public_ip" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.public_ip.ip_address
}
output "blob_storage_url" {
  description = "URL du stockage Blob"
  value       = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net/${azurerm_storage_container.blob_container.name}"
}
output "mysql_server_fqdn" {
  description = "FQDN du serveur MySQL"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}
output "mysql_database_name" {
  description = "Nom de la base de données MySQL"
  value       = azurerm_mysql_flexible_database.database.name
}



output "stockage_account_name" {
  description = "Nom du compte de stockage"
  value       = azurerm_storage_account.storage.name
  
}

output "vm_ssh_command" {
  description = "Commande SSH pour se connecter à la VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
}