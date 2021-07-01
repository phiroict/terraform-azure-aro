login:
	az login
init_az:
	az provider register -n Microsoft.RedHatOpenShift --wait
init:
	cd infrastructure && terraform init
delete_aro_cluster:
	az aro delete --name aro_cluster --resource-group MyResourceGroup
plan:
	cd infrastructure && terraform plan -out openshift.plan

apply:
	cd infrastructure && terraform apply openshift.plan
post_apply:
	bash ./post_processor.sh
destroy:
	cd infrastructure && terraform destroy
all: plan apply post_apply
import_dns:
	cd infrastructure && terraform import azurerm_private_dns_zone.privatedomain /subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/myresourcegroup/providers/Microsoft.Network/privateDnsZones/uluvus.private
bounce: destroy plan apply post_apply

console:
	chromium https://azure.microsoft.com/en-us/features/azure-portal/ &