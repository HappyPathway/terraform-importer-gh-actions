# terraform-gh_actions-import

This Terraform module enables automated mirroring of GitHub repositories with a focus on GitHub Actions workflows. It synchronizes content from a public GitHub repository to an internal repository while preserving all files, including GitHub Actions workflows, and maintaining repository metadata like descriptions and topics.

## Features

- Automatic synchronization of all files from source to destination repository
- Preservation of repository metadata (description, topics)
- Support for configuring repository access (collaborators, teams)
- Maintains GitHub Actions workflows and related files
- Fine-grained control over repository settings
- Built-in security with vulnerability alerts

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

## Outputs

| Name | Description |
|------|-------------|
| public_repo | Full details about the source repository |
| internal_repo | Full details about the created internal repository |

## How It Works

1. The module retrieves metadata from the source repository (description, topics, etc.)
2. Creates a new repository in the destination organization
3. Recursively copies all files from the source repository
4. Configures repository settings, collaborators, and teams
5. Maintains synchronization of files through Terraform state

## Notes

- All files are synchronized as-is, including GitHub Actions workflows
- The destination repository will be public by default
- Existing files in the destination repository will be overwritten
- Changes made directly to the destination repository may be overwritten on the next Terraform apply

## License

MIT

## Support

For issues and feature requests, please open an issue in the repository.
