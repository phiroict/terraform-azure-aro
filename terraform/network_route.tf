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
