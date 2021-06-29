login:
	az login
init:
	cd infrastructure && terraform init
plan:
	cd infrastructure && terraform plan -out openshift.plan
apply:
	cd infrastructure && terraform apply openshift.plan
destroy:
	cd infrastructure && terraform destroy
all: plan apply
import_dns:
	cd infrastructure && terraform import azurerm_private_dns_zone.privatedomain /subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/myresourcegroup/providers/Microsoft.Network/privateDnsZones/uluvus.private
bounce: destroy plan apply
console:
	chromium https://azure.microsoft.com/en-us/features/azure-portal/ &