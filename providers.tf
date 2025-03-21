provider "github" {
  alias = "public_repo"
  token = var.github_token
  owner = var.public_repo.org
  base_url = var.public_repo.base_url
}

# The default provider (without alias) will be used for the internal repository operations

