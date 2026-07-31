# This block tells Terraform which platform/provider we want to connect to.
# In this case, we are connecting Terraform to GitHub.
# Terraform itself cannot talk to GitHub directly.
# The GitHub provider gives Terraform the ability to create and manage GitHub resources.

provider "github" {
  token = var.github_token
}

# This is a resource block.
# Resources are the actual things Terraform creates and manages.
# In this example, Terraform will create a GitHub repository.
# Syntax:
# resource "provider_resource_type" "resource_name" {
#
# First value:
# "github_repository" = the type of resource we want to create.
# It comes from the GitHub provider.
#
# Second value:
# "production_repo" = the name we give this resource inside Terraform.
# This is only a Terraform name and does not become the GitHub repository name.
resource "github_repository" "production_repo" {
  name        = "prod-repo"
  description = "Repo for our production app"
  private     = true
}
