module "openshift-cluster-module" {
  source = "../terraform"
}

output "aro_call" {
  value = module.openshift-cluster-module.aro_create_command
}

output "tls_private_key_bastion" {
  value = module.openshift-cluster-module.tls_private_key
  sensitive = true
}