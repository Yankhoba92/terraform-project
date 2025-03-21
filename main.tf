resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroupnewyankhoba"
  location = "West US"
}
resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccountyankhoba" # Doit être unique !
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version           = "TLS1_2"
}
resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "my-mysql-serveryankhoba"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  administrator_login          = "adminuser"
  administrator_password       = "SuperSecret123!"
  sku_name                     = "B_Standard_B1ms"
  version                      = "8.0.21"
  backup_retention_days        = 7
}
resource "azurerm_mysql_flexible_database" "database" {
  name                = "mydatabaseyankhoba"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset            = "utf8"
  collation          = "utf8_general_ci"
}
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "74.235.235.206"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_storage_container" "blob_container" {
  name                  = "staticfiles"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"  # "private" pour sécuriser les fichiers
}
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

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
}
