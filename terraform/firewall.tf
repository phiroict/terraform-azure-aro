# Create the Azure Firewall
resource "azurerm_firewall" "azure_firewall" {
  depends_on=[azurerm_public_ip.azure_firewall_pip]
  name = "azure_firewall"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  location = azurerm_resource_group.myterraformgroup.location
  ip_configuration {
    name = "hg-core-azure-firewall-config"
    subnet_id = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.azure_firewall_pip.id
  }

  tags = merge(var.tags,{
    environment = "Terraform Demo"
  })
}

# Create a Azure Firewall Application Rule for Red Hat Websites
resource "azurerm_firewall_application_rule_collection" "fw-app-tech-websites" {
  name                = "fw-app-tech-websites"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  priority            = 1001
  action              = "Allow"
  rule {
    name = "All The OCP URLs"
    source_addresses = [var.traffic_source]
    target_fqdns = [
      "quay.io",
      "*.quay.io",
      "registry.redhat.io",
      "registry.access.redhat.com",
      "openshift.org",
      "*.openshift.org",
      "api.openshift.com",
      "infogw.api.openshift.com",
      "api.access.redhat.com",
      "cert-api.access.redhat.com",
      "sso.redhat.com",
      "management.azure.com",
      "cloud.redhat.com",
      "mirror.openshift.com",
      "mirror.openshift.com",
      "arosvc.azurecr.io",
      "login.microsoftonline.com",
      "gcs.prod.monitoring.core.windows.net",
      "*.servicebus.windows.net",
      "*.table.core.windows.net",
      "*.blob.core.windows.net"



    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }

}

# Create a Azure Firewall Network Rule for Azure Active Directoy
resource "azurerm_firewall_network_rule_collection" "fw-net-azure-ad" {
  name = "fw-net-azure-ad"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  priority = 104
  action = "Allow"

  ## All IPs can get to magic IP of Azure.
  rule {
    name = "AzureMagicAgent1"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["80"]
    destination_addresses = [var.allowed_ingress_ipaddress]
    protocols = ["TCP","UDP"]
  }
  rule {
    name = "AzureMagicAgent2"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["32526"]
    destination_addresses = [var.allowed_ingress_ipaddress]
    protocols = ["TCP","UDP"]
  }

  rule {
    name = "AzureDNS"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["53"]
    destination_addresses = [var.allowed_ingress_ipaddress]
    protocols = ["TCP","UDP"]
  }
}

### End Firewall

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags , {
    environment = "Terraform Demo"
  })
}
