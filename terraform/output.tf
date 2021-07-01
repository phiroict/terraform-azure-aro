output "tls_private_key" {
  value = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

output "aro_create_command" {
  value = "az aro create --resource-group ${azurerm_resource_group.myterraformgroup.name} --name aro_cluster --domain ${azurerm_private_dns_zone.privatedomain.name} --vnet ${azurerm_virtual_network.myterraformnetwork.name} --master-subnet ${azurerm_subnet.myControlPlaneSubnet.name} --worker-subnet ${azurerm_subnet.myWorkerSubnet.name} --apiserver-visibility Private --ingress-visibility Private --worker-vm-size Standard_D4as_v4 --location ${azurerm_resource_group.myterraformgroup.location} --pull-secret @pull-secret.txt"
}

output "aro_bastion" {
  value = "ssh -i id_temp_bastion ${azurerm_linux_virtual_machine.myterraformvm.admin_username}@${azurerm_linux_virtual_machine.myterraformvm.public_ip_address}"
}

output "aro_credential_list" {
  value = "az aro list-credentials --name aro_cluster --resource-group ${azurerm_resource_group.myterraformgroup.name}"
}

output "aro_url" {
  value = "az aro show --name aro_cluster --resource-group ${azurerm_resource_group.myterraformgroup.name} --query 'consoleProfile.url' -o tsv"
}

output "aro_internal_addresses_list" {
  value = "az aro show -n aro_cluster -g ${azurerm_resource_group.myterraformgroup.name} --query '{api:apiserverProfile.ip, ingress:ingressProfiles[0].ip}'"
}