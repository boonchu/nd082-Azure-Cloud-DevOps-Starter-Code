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


resource "azurerm_network_security_group" "this" {
  name                = "${var.prefix}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    role = var.role
  }
}


resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.this.id
}


resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static" 
  domain_name_label   = "${var.prefix}-public-ip"
  tags = {
    role = var.role
  }
}


resource "azurerm_lb" "this" {
  name                = "${var.prefix}-public-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-public-lb"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  tags = {
    role = var.role
  }
}


resource "azurerm_lb_backend_address_pool" "this" {
  resource_group_name = azurerm_resource_group.this.name
  loadbalancer_id     = azurerm_lb.this.id
  name                = "${var.prefix}-members-pool"
}


resource "azurerm_lb_probe" "this" {
  resource_group_name = azurerm_resource_group.this.name
  loadbalancer_id     = azurerm_lb.this.id
  name                = "http-lb-health-probe"
  port                = 80
}


resource "azurerm_lb_rule" "this" {
  resource_group_name            = azurerm_resource_group.this.name
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "http-lb-healthcheck-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-public-lb"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.this.id
  probe_id                       = azurerm_lb_probe.this.id
  idle_timeout_in_minutes        = 30
}


resource "azurerm_network_interface" "this" {
  count               = var.number-of-vms

  name                = "${var.prefix}-vif${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  ip_configuration {
    name                          = "${var.prefix}-vif${count.index}"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    role = var.role
  }
}


resource "azurerm_network_interface_backend_address_pool_association" "this" {
  count                   = var.number-of-vms

  network_interface_id    = element(azurerm_network_interface.this.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-vif${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
}


resource "azurerm_availability_set" "this" {
  name                = "${var.prefix}-availabilityset"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  /* 
    The number of Update Domains varies depending on which Azure Region. See documents.
    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set
    https://github.com/MicrosoftDocs/azure-docs/blob/master/includes/managed-disks-common-fault-domain-region-list.md
  */
  platform_fault_domain_count = 2

  tags = {
    role = var.role
  }
}


resource "azurerm_virtual_machine" "this" {
  count               = var.number-of-vms

  depends_on          = [azurerm_network_interface.this, azurerm_availability_set.this]

  name                = "${var.prefix}-vm${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vm_size             = "Standard_B1s"
  network_interface_ids = [
    element(azurerm_network_interface.this.*.id, count.index)
  ]
  availability_set_id = azurerm_availability_set.this.id

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "${var.prefix}-vm${count.index}"
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
    name              = "${var.prefix}-vmbootdisk${count.index}"
    os_type           = "linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    role = var.role
  }
}


resource "azurerm_managed_disk" "this" {
  count                = var.number-of-vms

  name                 = "${var.prefix}-data-vmdisk${count.index}"
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = {
    role = var.role
  }
}


resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count	             = var.number-of-vms
  managed_disk_id    = azurerm_managed_disk.this.*.id[count.index]

  virtual_machine_id = element(azurerm_virtual_machine.this.*.id, count.index)
  lun                = "10"
  caching            = "ReadWrite"
}
