resource "github_repository" "testing_repo" {
  name        = "test-repo"
  description = "Repo for our production app"
  private     = true
}