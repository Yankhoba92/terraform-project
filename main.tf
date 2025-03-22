# Création du groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroupnewyankhoba"
  location = "West US"
}

# Création du compte de stockage
resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccountyankhoba" # Doit être unique !
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# Création du serveur MySQL flexible
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "my-mysql-serveryankhoba"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  administrator_login    = "adminuser"
  administrator_password = "SuperSecret123!"
  sku_name              = "B_Standard_B1ms"
  version               = "8.0.21"
  backup_retention_days = 7
}

# Création de la base de données MySQL
resource "azurerm_mysql_flexible_database" "database" {
  name                = "mydatabaseyankhoba"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

# Règle de pare-feu pour MySQL
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Création du conteneur de stockage Blob
resource "azurerm_storage_container" "blob_container" {
  name                  = "staticfiles"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Création du réseau virtuel
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Création du sous-réseau
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Création de l'IP publique
resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Création de l'interface réseau
resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myIPConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Création de la machine virtuelle
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C:/Users/Yankhoba/.ssh/id_rsa.pub") # Chemin absolu de votre clé SSH
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Provisioner pour exécuter le script de configuration
 # Provisioner pour installer Node.js et déployer le backend
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl",
      "curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -", # Installer Node.js 16.x
      "sudo apt-get install -y nodejs",
      "sudo npm install -g pm2", # Installer PM2 pour gérer le processus Node.js
      "mkdir -p /home/${var.admin_username}/app",
      "echo 'const express = require(\"express\");\nconst app = express();\n\napp.get(\"/\", (req, res) => {\n  res.send(\"Hello, World from Node.js!\");\n});\n\napp.listen(3000, () => {\n  console.log(\"Server running on port 3000\");\n});' > /home/${var.admin_username}/app/index.js",
      "echo '{\n  \"name\": \"myapp\",\n  \"version\": \"1.0.0\",\n  \"main\": \"index.js\",\n  \"scripts\": {\n    \"start\": \"node index.js\"\n  },\n  \"dependencies\": {\n    \"express\": \"^4.17.1\"\n  }\n}' > /home/${var.admin_username}/app/package.json",
      "cd /home/${var.admin_username}/app && npm install",
      "pm2 start /home/${var.admin_username}/app/index.js --name \"myapp\"", # Démarrer l'application avec PM2
      "pm2 save", # Sauvegarder la configuration PM2
      "pm2 startup", # Configurer PM2 pour démarrer au boot
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = file(var.admin_ssh_private_key)
      host        = azurerm_public_ip.public_ip.ip_address
    }
  }
    depends_on = [azurerm_public_ip.public_ip]
}