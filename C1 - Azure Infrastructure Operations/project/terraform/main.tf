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
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm-1"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  size                            = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]


  admin_username                  = "adminuser"
  /*
  admin_password                  = "P@ssw0rd1234!"
  */
  disable_password_authentication = true
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  // https://gmusumeci.medium.com/how-to-find-azure-linux-vm-images-for-terraform-or-packer-deployments-24e8e0ac68a
  /*
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  */
  // find id from packer build, az image list --resource-group packer-rg -o json | jq .'[]'.id
  source_image_id = "/subscriptions/2fc77d44-a037-4e7b-822c-d51f8788b873/resourceGroups/packer-rg/providers/Microsoft.Compute/images/Ubuntu_image_1804_lts"

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
