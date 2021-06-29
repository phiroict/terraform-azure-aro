# Create the public ip for Azure Firewall
resource "azurerm_public_ip" "azure_firewall_pip" {
  name = "azure_firewall_pip"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  location = azurerm_resource_group.myterraformgroup.location
  allocation_method = "Static"
  sku = "Standard"
  tags = merge(var.tags, {
    environment = "Terraform Demo"
  })
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                         = "myPublicIP"
  location                     = azurerm_resource_group.myterraformgroup.location
  resource_group_name          = azurerm_resource_group.myterraformgroup.name
  allocation_method            = "Dynamic"

  tags = merge(var.tags,{
    environment = "Terraform Demo"
  })
}

resource "azurerm_private_dns_zone" "privatedomain" {
  name                = "uluvus.private"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  tags = var.tags
}
