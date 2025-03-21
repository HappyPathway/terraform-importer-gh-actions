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
  
  # Pass the GitHub token to the module
  github_token = module.gh_token.value
  
  public_repo = {
    clone_url      = "https://github.com/HappyPathway/terraform-importer-gh-actions.git"
    default_branch = "main"
  }
  
  internal_repo = {
    name   = "terraform-import-gh-actions-internal"
    org    = "HappyPathway"
    topics = ["github-actions"]
  }
  
  # No need to pass providers anymore
}
