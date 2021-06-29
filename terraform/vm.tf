# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                   = var.vm_name
  location               = azurerm_resource_group.myterraformgroup.location
  resource_group_name    = azurerm_resource_group.myterraformgroup.name
  network_interface_ids  = [azurerm_network_interface.myterraformnic.id]
  size                   = var.vm_size

  os_disk {
    name                 = var.vm_os_disk.name
    caching              = var.vm_os_disk.caching
    storage_account_type = var.vm_os_disk.storage_account_type
  }

  source_image_reference {
    publisher            = var.vm_source_image.publisher
    offer                = var.vm_source_image.offer
    sku                  = var.vm_source_image.sku
    version              = var.vm_source_image.version
  }

  computer_name  = var.vm_name
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username       = "azureuser"
    public_key     = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = merge(var.tags, {
    environment = "Terraform Demo"
  })
}
