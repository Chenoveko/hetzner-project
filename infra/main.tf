locals {
  common_labels = {
    project   = var.project_name
    managedBy = "terraform"
    owner     = var.owner
  }
}
