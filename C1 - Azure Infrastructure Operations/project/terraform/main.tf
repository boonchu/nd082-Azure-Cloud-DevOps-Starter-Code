provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    role = var.role
  }
}

resource "azurerm_subnet" "private" {
  name                 = "private_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-public-ip-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-public-ip"
  tags = {
    role = var.role
  }
}

resource "azurerm_network_interface" "this" {
  name                = "${var.prefix}-nic-1"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = {
    role = var.role
  }
}

resource "azurerm_virtual_machine" "this" {
  depends_on          = [azurerm_network_interface.this]

  name                = "${var.prefix}-vm-1"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vm_size             = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "${var.prefix}-vm-1"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")
      path     = "/home/adminuser/.ssh/authorized_keys"
    }
  }

  // https://gmusumeci.medium.com/how-to-find-azure-linux-vm-images-for-terraform-or-packer-deployments-24e8e0ac68a
  storage_image_reference  {
    id        = lookup(var.linux-vm-image, "id", null)
    offer     = lookup(var.linux-vm-image, "offer", null)
    publisher = lookup(var.linux-vm-image, "publisher", null)
    sku       = lookup(var.linux-vm-image, "sku", null)
    version   = lookup(var.linux-vm-image, "version", null)
  }

  storage_os_disk {
    name              = "${var.prefix}-vm-os-disk"
    os_type           = "linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    role = var.role
  }
}
