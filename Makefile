login:
	az login
init:
	cd infrastructure && terraform init
plan:
	cd infrastructure && terraform plan -out openshift.plan
apply:
	cd infrastructure && terraform apply openshift.plan
console:
	chromium https://azure.microsoft.com/en-us/features/azure-portal/ &