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
  alias = "public_repo"
  token = module.gh_token.value
  owner = "HappyPathway"
}

provider "github" {
  alias = "internal_repo"
  token = module.gh_token.value
  owner = "HappyPathway"
}

module "repo_mirror" {
  source = "../"
  public_repo = {
    org            = "HappyPathway"
    name           = "terraform-importer-gh-actions"
    clone_url      = "https://github.com/HappyPathway/terraform-importer-gh-actions.git"
    default_branch = "main"
  }
  internal_repo = {
    name   = "terraform-import-gh-actions-internal"
    org    = "HappyPathway"
    topics = ["github-actions"]
  }
  github_repo_topics = ["testing", "terraform"]
  providers = {
    github.public   = github.public_repo
    github.internal = github.internal_repo
  }
}
