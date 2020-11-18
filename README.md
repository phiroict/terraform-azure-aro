# terraform-azure-ocp
This code will first standup VNET, Bastion and firewall for the Azure Private network.

This hat can be used to run openshift install for internal network.

## Start by creating the infrastructure on Azure.
IMPORTANT: First ensure you are logged into the right Azure account.

```# az login```

Initialise your terraform directory.

```# terraform init```

Run the plan

```terraform plan```


