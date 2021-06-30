module "openshift-cluster-module" {
  source = "../terraform"

  # Params #############################################################################################################
  allowed_ingress_ipaddress = var.allowed_ingress_ipaddress
  controlpane_subnet_name = var.controlpane_subnet_name
  resourcegroup_name = var.resourcegroup_name
  subnet_firewall = var.subnet_firewall
  terraform_subnet_name = var.terraform_subnet_name
  traffic_source = var.traffic_source
  vm_name = var.vm_name
  vmnet_name = var.vmnet_name
  vm_os_disk = var.vm_os_disk
  vm_source_image = var.vm_source_image
  workerpane_subnet_name = var.workerpane_subnet_name
  vm_size = var.vm_size
  subnets_planes = var.subnets_planes
}

output "aro_call" {
  value = module.openshift-cluster-module.aro_create_command
}

output "tls_private_key_bastion" {
  value = module.openshift-cluster-module.tls_private_key
  sensitive = true
}

output "aro_cred_list" {
  value = module.openshift-cluster-module.aro_credential_list
}

output "aro_cred_url" {
  value = module.openshift-cluster-module.aro_url
}

output "aro_bastion" {
  value = module.openshift-cluster-module.aro_bastion
}

output "aro_internal_addresses_call" {
  value = module.openshift-cluster-module.aro_internal_addresses_list
}