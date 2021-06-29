# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = var.resourcegroup_name
  location = "southeastasia"

  tags = merge(var.tags, {
    Name="OCP Private Terraform Demo"
    CreatedAt = formatdate("YYYY MM DD hh:mm ZZZ", timestamp())
    ExpiresAt = formatdate("YYYY MM DD hh:mm ZZZ", timeadd(timestamp(),"240h"))
  } )

}