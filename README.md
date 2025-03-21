# terraform-gh_actions-import

This Terraform module enables automated mirroring of GitHub repositories with a focus on GitHub Actions workflows. It synchronizes content from a public GitHub repository to an internal repository while preserving all files, including GitHub Actions workflows, and maintaining repository metadata like descriptions and topics.

## Features

- Automatic synchronization of all files from source to destination repository using native GitHub provider
- Preservation of repository metadata (description, topics)
- Support for configuring repository access (collaborators, teams)
- Maintains GitHub Actions workflows and related files
- Fine-grained control over repository settings
- Built-in security with vulnerability alerts
- Improved reliability through native GitHub API integration

## Usage

```hcl
module "repo_mirror" {
  source = "github.com/your-org/terraform-gh_actions-import"
  
  public_repo = {
    owner = "original-org"
    name  = "original-repo"
  }
  
  internal_repo = {
    name   = "internal-repo-copy"
    org    = "your-org"
    topics = ["github-actions"]  # Additional topics will be merged with source
  }

  source_default_branch = "main"  # Optional: specify default branch

  providers = {
    github.public_repo   = github.public
    github.internal_repo = github.internal
  }
}
```

## Requirements

- Terraform >= 1.0
- GitHub Provider >= 6.2.2
- GitHub access tokens with appropriate permissions for both source and destination repositories

## Provider Configuration

This module requires two provider configurations:

1. `github.public_repo` - For accessing the source repository
2. `github.internal_repo` - For managing the destination repository

Example provider configuration:

```hcl
provider "github" {
  alias = "public_repo"
  token = var.github_token
  owner = "source-org"
}

provider "github" {
  alias = "internal_repo"
  token = var.internal_github_token
  owner = "destination-org"
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| public_repo | Configuration for the source repository | object({ owner = string, name = string }) |
| internal_repo | Configuration for the destination repository | object({ name = string, org = string, ... }) |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| internal_repo.topics | Additional topics to add to the repository | list(string) | [] |
| internal_repo.collaborators | Map of collaborators and their permission levels | map(string) | {} |
| internal_repo.admin_teams | List of teams to grant admin access | list(string) | [] |
| github_org_teams | GitHub organization teams to add to the repository | list(any) | [] |
| vulnerability_alerts | Enable GitHub vulnerability alerts | bool | true |
| source_default_branch | Default branch to use for the repository | string | "main" |

## Outputs

| Name | Description |
|------|-------------|
| public_repo | Full details about the source repository |
| internal_repo | Full details about the created internal repository |

## How It Works

1. The module retrieves metadata from the source repository (description, topics, etc.)
2. Creates a new repository in the destination organization
3. Uses GitHub's API to copy all files from source to destination
4. Configures repository settings, collaborators, and teams
5. Maintains synchronization through native GitHub provider resources

## Notes

- Files are synchronized using GitHub's native API, providing better reliability
- The destination repository will be public by default
- Existing files in the destination repository will be overwritten
- Changes made directly to the destination repository may be overwritten on the next Terraform apply
- Repository synchronization is triggered automatically when the source repository changes

## License

MIT

## Support

For issues and feature requests, please open an issue in the repository.

[![Terraform Validation](https://github.com/HappyPathway/terraform-importer-gh-actions/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-importer-gh-actions/actions/workflows/terraform.yaml)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internal_github_actions"></a> [internal\_github\_actions](#module\_internal\_github\_actions) | HappyPathway/repo/github | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.git_import](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force"></a> [force](#input\_force) | n/a | `bool` | `false` | no |
| <a name="input_github_org_teams"></a> [github\_org\_teams](#input\_github\_org_teams) | The GitHub organization teams to add to the repository | `list(any)` | `[]` | no |
| <a name="input_github_repo_topics"></a> [github\_repo\_topics](#input\_github\_repo_topics) | n/a | `list(string)` | n/a | yes |
| <a name="input_internal_repo"></a> [internal\_repo](#input\_internal_repo) | The internal GitHub repository to create | <pre>object({<br>    name          = string<br>    org           = string<br>    topics        = optional(list(string), [])<br>    collaborators = optional(map(string), {})<br>    admin_teams   = optional(list(string), [])<br>  })</pre> | n/a | yes |
| <a name="input_public_repo"></a> [public\_repo](#input\_public_repo) | The public GitHub repository to import | <pre>object({<br>    clone_url      = string<br>    default_branch = string<br>  })</pre> | n/a | yes |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability_alerts) | Enable GitHub vulnerability alerts | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_repo"></a> [internal\_repo](#output\_internal_repo) | n/a |
<!-- END_TF_DOCS -->
