# In our directory we can have many terraform files
# and they will be able to communicate between each other
# we can have the same name address for two blocks

resource "github_repository" "testing_repo" {
  name        = "test-repo"
  description = "Repo for our production app"
  private     = true
}