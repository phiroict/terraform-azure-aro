output "tls_private_key" {
  value = tls_private_key.example_ssh.private_key_pem
}

output "aro_create_command" {
  value = "az aro create --resource-group ${azurerm_resource_group.myterraformgroup.name} --name aro_cluster --domain ${azurerm_private_dns_zone.privatedomain.name} --vnet ${azurerm_virtual_network.myterraformnetwork.name} --master-subnet ${azurerm_subnet.myControlPlaneSubnet.name} --worker-subnet ${azurerm_subnet.myWorkerSubnet.name} --apiserver-visibility Private --ingress-visibility Private --worker-vm-size Standard_D4as_v4 --location ${azurerm_resource_group.myterraformgroup.location} --pull-secret @pull-secret.txt"
}