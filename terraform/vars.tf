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
  default = ["10.5.0.0/24","10.6.0.0/24","10.7.0.0/24"]
}

variable "traffic_source" {
  type = string
  default = "10.0.0.0/16"
}