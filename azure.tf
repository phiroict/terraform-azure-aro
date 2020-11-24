# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "southeastasia"

    tags = {
        environment = "OCP Private Terraform Demo"
    }
}


# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create control plane subnet
resource "azurerm_subnet" "myControlPlaneSubnet" {
    name                 = "myControlPlaneSubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

# Create worker subnet
resource "azurerm_subnet" "myWorkerSubnet" {
    name                 = "myWorkerSubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.3.0/24"]
}

### Start Firewall

# Create firewall subnet
resource "azurerm_subnet" "AzureFirewallSubnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.10.0/24"]
}

# Create the public ip for Azure Firewall
resource "azurerm_public_ip" "azure_firewall_pip" {
  name = "azure_firewall_pip"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  location = azurerm_resource_group.myterraformgroup.location
  allocation_method = "Static"
  sku = "Standard"
  tags = {
    environment = "Terraform Demo"
  }
}

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
 
  tags = {
    environment = "Terraform Demo"
  }
}

# Create a Azure Firewall Application Rule for Red Hat Websites
resource "azurerm_firewall_application_rule_collection" "fw-app-tech-websites" {
  name                = "fw-app-tech-websites"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  priority            = 1001
  action              = "Allow"
  rule {
    name = "Registry Red Hat"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = ["registry.redhat.io"]
    protocol {
      port = "443"
      type = "Https"
    }
  }

    rule {
    name = "Quay"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = [
      "quay.io",
      "*.quay.io"
      ]
    protocol {
      port = "443"
      type = "Https"
    }
  }

      rule {
    name = "Openshift.org"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = ["openshift.org", "*.openshift.org"]
    protocol {
      port = "443"
      type = "Https"
    }
  }


      rule {
    name = "openshift.com"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = ["api.openshift.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }

  ## All IPs can get to management of Azure.
  rule {
    name = "Azure"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = ["management.azure.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }

    ## All IPs can get to management of Azure.
  rule {
    name = "LoginMicrosoft"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = ["login.microsoftonline.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }

#Blob storage is used to get the ignition files. This needs to be made into a private link so this rule can be removed. It can actually be removed as soon as the bootstrap node starts.
  rule {
    name = "AzureBlob"
    source_addresses = ["10.0.0.0/16"]
    target_fqdns = ["*.blob.core.windows.net"]
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
    destination_addresses = ["168.63.129.16"]
    protocols = ["TCP","UDP"]
  }

    rule {
    name = "AzureMagicAgent2"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["32526"]
    destination_addresses = ["168.63.129.16"]
    protocols = ["TCP","UDP"]
  }

    rule {
    name = "AzureDNS"   
    source_addresses = ["10.0.0.0/16"]    
    destination_ports = ["53"]
    destination_addresses = ["168.63.129.16"]
    protocols = ["TCP","UDP"]
  }

}

### End Firewall

### Create route to firewall

resource "azurerm_route_table" "firewall_routetable" {
  depends_on=[azurerm_firewall.azure_firewall]
  name                = "firewall_routetable"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  route {
    name                   = "internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azure_firewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "route_control_plane" {
  subnet_id      = azurerm_subnet.myControlPlaneSubnet.id
  route_table_id = azurerm_route_table.firewall_routetable.id
}

resource "azurerm_subnet_route_table_association" "route_workers" {
  subnet_id      = azurerm_subnet.myWorkerSubnet.id
  route_table_id = azurerm_route_table.firewall_routetable.id
}

### End route to firewall


# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = azurerm_resource_group.myterraformgroup.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

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

    tags = {
        environment = "Terraform Demo"
    }
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

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = azurerm_resource_group.myterraformgroup.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}
