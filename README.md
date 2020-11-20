# terraform-azure-ocp
This code will first standup VNET, Bastion and firewall for the Azure Private network.

This can be used to run openshift install for internal network.

# Creating the infrastructure on Azure.
IMPORTANT: First ensure you are logged into the right Azure account.

`# az login`

Initialise your terraform directory.

`# terraform init`

Run the plan

`# terraform plan`

Apply to the infra

`# terraform apply`

After the install, create your private key and use it to access the Bastion host which was created in the terraform apply.

The result of applying the terraform will be the following:
* 1 VNET and 4 subnets (mySubnet, myControlPlaneSubnet, myWorkerSubnet, AzureFirewallSubnet)
* 1 firewall with static IP address
* Firewall rules to allow internal subnets access to the addresses required to install OpenShift (ie quay.io)
* 1 routing table which adds the worker and control plane subnets to default routing to the firewall.
* 1 CentOS VM which we will use for Bastion, this also has a dynamic public IP address (may change to use firewall later)


# Configure Bastion host:

## Install the Azure client

### Add RPM

`# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc`

### Prepare azure repo info

```
sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
```

### Install azure cli

`# sudo yum install azure-cli`

## Install Openshift oc client

`# wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz`

`# tar -xvf oc.tar.gz`

Copy the oc client into $PATH (yours may be different, you can see we need to create the directory here)

`# mkdir -p ~/.local/bin`

`# sudo cp ./oc ~/.local/bin`

##Download the Installer

` # wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-install-linux.tar.gz`

` # tar -xvf openshift-install-linux.tar.gz`

` # sudo cp ./openshift-install ~/.local/bin`

# Install jq

Because it is handy for working with OCP and Azure.

`sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

`sudo yum install jq`

# Follow this guide to prepare your azure client:
https://docs.openshift.com/container-platform/latest/installing/installing_azure/installing-azure-account.html

# Prepare your install-config.yaml for openshift.
You can download the example from this repo into your working directory.
`# wget https://github.com/thoward-rh/terraform-azure-ocp/blob/main/install-config.yaml`
Key items to edit are your base domain, pull secret (from cloud.openshift.com), and your ssh public key.

# Run the openshift installer
I like to run with full debug on so I can see what is happening.
`# openshift-install create cluster --dir . --log-level debug`


# Things to do
* Turn Bastion into a node to host registry, then block the red hat registry for nodes.
* Ensure items such as blob are accessed as internal links, not external.