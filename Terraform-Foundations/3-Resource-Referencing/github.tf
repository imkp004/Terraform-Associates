provider "github" {
  token = var.github_token
}

resource "github_repository" "production_repo" {
  name        = "prod-repo"
  description = "Repo for our production app"
  private     = true
}
