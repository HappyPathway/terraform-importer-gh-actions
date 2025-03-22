terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
  }
}

module "gh_token" {
  source  = "HappyPathway/var/env"
  env_var = "GITHUB_TOKEN"
}

provider "github" {
  token = module.gh_token.value
  owner = "HappyPathway"  # Owner for the internal repository operations
}

module "repo_mirror" {
  source = "../"
  
  github_token = module.gh_token.value
  public_repo = {
    org            = "HappyPathway"
    name           = "terraform-importer-gh-actions"
    default_branch = "main"
  }
  
  internal_repo = {
    name   = "terraform-import-gh-actions-internal"
    org    = "HappyPathway"
    topics = ["github-actions"]
  }
}
