provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload_name}-${var.location_short}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.workload_name}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]
}

resource "azurerm_subnet" "vm" {
  name                 = "subnet-${var.workload_name}-${var.location_short}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.workload_name}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]
  size = var.vm_size

  os_disk {
    name                 = "osdisk-${var.workload_name}-${var.location_short}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "ubuvm"
  admin_username                  = "vpnadmin"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "vpnadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  custom_data = base64encode(templatefile("cloud_init.txt", {
    server_address     = var.server_address,
    server_private_key = var.server_private_key,
    server_allowed_ips = var.subnet_address_prefix,
    client_public_key  = var.client_public_key,
  }))
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-${var.workload_name}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.workload_name}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm-ip-config"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm_private_ip
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-${var.workload_name}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = trimspace(data.http.my_ip.response_body)
  destination_address_prefix  = var.vm_private_ip
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_network_security_rule" "allow_wireguard" {
  name                        = "allow-wireguard"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "51820"
  source_address_prefix       = trimspace(data.http.my_ip.response_body)
  destination_address_prefix  = var.vm_private_ip
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "local_file" "wg_client_config" {
  content = templatefile("${path.module}/wg_client_config.tpl", {
    client_private_key = var.client_private_key,
    client_address     = var.client_address,
    server_public_key  = var.server_public_key,
    vm_public_ip       = data.azurerm_public_ip.vm.ip_address
  })
  filename = "${path.module}/wg_${var.workload_name}_${var.location_short}.conf"
}

data "azurerm_public_ip" "vm" {
  name                = azurerm_public_ip.vm.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_linux_virtual_machine.vm]
}

output "vm_public_ip" {
  value = data.azurerm_public_ip.vm.ip_address
}