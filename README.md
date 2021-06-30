# terraform-azure-aro
This code will first standup VNET, Bastion and firewall for the Azure Private network.

This can be used to run ARO install for internal network.

The original project made by `thoward-rh` has been turned into a module so it inspires more reuse. 

Base setup: 

![Diagram system](docs/images/ARO_Baseline_Infra.jpg)


# Creating the infrastructure on Azure.
IMPORTANT: First ensure you are logged into the right Azure account with the right access.
You also need into increase the standard CPU allocations / ensure these are sufficient. 
You need for running the demo ARO cluster that is generated by:  

`az aro create --resource-group MyResourceGroup --name aro_cluster --vnet myVnet --master-subnet myControlPlaneSubnet --worker-subnet myWorkerSubnet --apiserver-visibility Private --ingress-visibility Private --worker-vm-size Standard_D4as_v4`

These quotas

| CPU family | Number of vCPUs | Default for PayG sub |
| --- | --- | --- |
| Cores | 50 | 10 |
| standardDSv3Family | 20 | 10 | 
| standardDASv4Family | 20 | 10 |


Before you start log in to the correct subscription 


`make login`

Make sure you enable the redhat repo in your Azure subscription, you need to do this only once.

`make init_az`


Initialise your terraform directory. You need this once, and also when the module is changed. 

`make init`

Run the plan

`make plan`

Apply to the infra

`make apply`

You can do plan and appy in one go 

`make all`

After the install, create your private key and use it to access the Bastion host which was created in the terraform apply.

The result of applying the terraform will be the following:
* 1 VNET and 4 subnets (mySubnet, myControlPlaneSubnet, myWorkerSubnet, AzureFirewallSubnet)
* 1 firewall with static IP address
* Firewall rules to allow internal subnets access to the addresses required to install OpenShift (ie quay.io)
* 1 routing table which adds the worker and control plane subnets to default routing to the firewall. User Defined Routing (UDR)
* 1 CentOS VM which we will use for Bastion, this also has a dynamic public IP address (may change to use firewall later)
* The commandline `az aro create ...` you need to run to create the cluster, note that you need to have set up the CPU quotas first.


# Create cluster variables

```bash

LOCATION=southeastasia                 # the location of your cluster
RESOURCEGROUP=myResourceGroup            # the name of the resource group where you want to create your cluster
CLUSTER=cluster                 # the name of your cluster
VNET=myVnet
SUBNETMASTER=myControlPlaneSubnet
SUBNETWORKER=myWorkerSubnet

```

# Create cluster

This is generated by the output, but you can run this as a custom command as well: 
```bash
az aro create \
  --resource-group $RESOURCEGROUP \
  --name $CLUSTER \
  --vnet $VNET \
  --master-subnet $SUBNETMASTER \
  --worker-subnet $SUBNETWORKER \
  --apiserver-visibility Private \
  --ingress-visibility Private \
  --domain uluvus.private \
  --pull-secret @pull-secret.txt
  # don't forget to add "\" if you remove the comments.
```

The generated command likes like: 

```text
Outputs:

aro_call = "az aro create --resource-group MyResourceGroup --name aro_cluster --domain uluvus.private --vnet myVnet --master-subnet myControlPlaneSubnet --worker-subnet myWorkerSubnet --apiserver-visibility Private --ingress-visibility Private --worker-vm-size Standard_D4as_v4 --location australiaeast --pull-secret @pull-secret.txt"

```

# Installation of ARO

Run the generated set this will return the configuration, for instance:

```json
{
  "apiserverProfile": {
    "ip": "10.0.2.4",
    "url": "https://api.uluvus.private:6443/",
    "visibility": "Private"
  },
  "clusterProfile": {
    "domain": "uluvus.private",
    "pullSecret": null,
    "resourceGroupId": "/subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourcegroups/aro-b72hpy87",
    "version": "4.6.26"
  },
  "consoleProfile": {
    "url": "https://console-openshift-console.apps.uluvus.private/"
  },
  "id": "/subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/MyResourceGroup/providers/Microsoft.RedHatOpenShift/openShiftClusters/aro_cluster",
  "ingressProfiles": [
    {
      "ip": "10.0.3.254",
      "name": "default",
      "visibility": "Private"
    }
  ],
  "location": "australiaeast",
  "masterProfile": {
    "subnetId": "/subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/myControlPlaneSubnet",
    "vmSize": "Standard_D8s_v3"
  },
  "name": "aro_cluster",
  "networkProfile": {
    "podCidr": "10.128.0.0/14",
    "serviceCidr": "172.30.0.0/16"
  },
  "provisioningState": "Succeeded",
  "resourceGroup": "MyResourceGroup",
  "servicePrincipalProfile": {
    "clientId": "2dc97634-cba2-4b7b-b7d3-2782b61c3c40",
    "clientSecret": null
  },
  "tags": null,
  "type": "Microsoft.RedHatOpenShift/openShiftClusters",
  "workerProfiles": [
    {
      "count": 1,
      "diskSizeGb": 128,
      "name": "aro-cluster-h5wn8-worker-australiaeast1",
      "subnetId": "/subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/myWorkerSubnet",
      "vmSize": "Standard_D4as_v4"
    },
    {
      "count": 1,
      "diskSizeGb": 128,
      "name": "aro-cluster-h5wn8-worker-australiaeast2",
      "subnetId": "/subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/myWorkerSubnet",
      "vmSize": "Standard_D4as_v4"
    },
    {
      "count": 1,
      "diskSizeGb": 128,
      "name": "aro-cluster-h5wn8-worker-australiaeast3",
      "subnetId": "/subscriptions/1d78ad94-cfa6-4756-98a3-7430270e6b39/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/myWorkerSubnet",
      "vmSize": "Standard_D4as_v4"
    }
  ]
}

```

## Access the ARO stack 
### credentials
List the credentials

```bash
az aro list-credentials --name aro_cluster --resource-group MyResourceGroup
```

Now get the url to open the console. 

```bash
az aro show --name aro_cluster --resource-group MyResourceGroup --query "consoleProfile.url" -o tsv
```

You need to get the private key from the tfstate file as terraform will not print it.


### Logging in 
Get the internal address and the bastion ip address

```bash
az aro show -n aro_cluster -g MyResourceGroup  --query '{api:apiserverProfile.ip, ingress:ingressProfiles[0].ip}'
# Returns (example): 
{
  "api": "10.0.2.4",
  "ingress": "10.0.3.254"
}

```
Get the bastion from the terraform output (example): 
```bash
aro_bastion = "Bastion ip : ssh -i id_temp_bastion azureuser@20.58.164.239"
```

Logon to the bastion by this (example):
```ssh
sudo ssh -i id_temp_bastion azureuser@20.58.164.239 -L 443:10.0.3.254:443

sudo ssh -i id_temp_bastion azureuser@<bastion_ip> -L 443:<ingress>:443
```
Note that you need to run as root to be allowed to forward to the sub 1024 443 port.

Now place these lines in the /etc/hosts file 

```text
127.0.0.1 console-openshift-console.apps.uluvus.private 
127.0.0.1 oauth-openshift.apps.uluvus.private
```

So now you can go to `https://console-openshift-console.apps.uluvus.private` to get to the cluster.