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