terraform {
  required_providers {
    github = {
      source = "hashicorp/github"
      configuration_aliases = [
        github.public,
      ]
    }
  }
}
