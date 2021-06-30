variable "resourcegroup_name" {
  default = "MyResourceGroup"
  type = string
}

variable "tags" {
  default = {
    Type = "PoC"
    State = "Experimental"
    Persistance = "Transient"
    Owner = "Philip Rodrigues"
    Project = "BNZ"
  }
}

variable "subnets_planes" {
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "subnet_firewall" {
  default = "10.0.10.0/24"
}

variable "traffic_source" {
  type = string
  default = "10.0.0.0/16"
}

variable "vm_source_image" {
  default = {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
}

variable "vm_os_disk" {
  default = {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

variable "vm_name" {
  default = "MyVM"
}

variable "vm_size" {
  default = "Standard_DS1_v2"
}

variable "vmnet_name" {
  default = "myVnet"
}

variable "terraform_subnet_name" {
  default = "myTerraformSubnet"
}

variable "controlpane_subnet_name" {
  default = "myControlPlaneSubnet"
}

variable "workerpane_subnet_name" {
  default = "myWorkerSubnet"
}

variable "allowed_ingress_ipaddress" {
  default = "151.210.139.77"
  type = string
}