# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = var.vmnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = merge(var.tags, {
    environment = "Terraform Demo"
    CreatedAt = formatdate("YYYY MM DD hh:mm ZZZ", timestamp())
    ExpiresAt = formatdate("YYYY MM DD hh:mm ZZZ", timeadd(timestamp(),"240h"))
    Name = "Openshift VNet"
  } )
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = var.terraform_subnet_name
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes       = [var.subnets_planes[0]]

}

# Create control plane subnet
resource "azurerm_subnet" "myControlPlaneSubnet" {
  name                 = var.controlpane_subnet_name
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes       = [var.subnets_planes[1]]
  service_endpoints = ["Microsoft.ContainerRegistry"]
  enforce_private_link_service_network_policies = true
}

# Create worker subnet
resource "azurerm_subnet" "myWorkerSubnet" {
  name                 = var.workerpane_subnet_name
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes       = [var.subnets_planes[2]]
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

# Create firewall subnet
resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes       = [var.subnet_firewall]
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                      = "myNIC"
  location                  = azurerm_resource_group.myterraformgroup.location
  resource_group_name       = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = merge(var.tags,{
    environment = "Terraform Demo"
  })
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}
