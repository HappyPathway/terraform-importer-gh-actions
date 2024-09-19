# terraform-gh_actions-import
Terraform Workspace

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
| <a name="input_github_org_teams"></a> [github\_org\_teams](#input\_github\_org\_teams) | The GitHub organization teams to add to the repository | `list(any)` | `[]` | no |
| <a name="input_github_repo_topics"></a> [github\_repo\_topics](#input\_github\_repo\_topics) | n/a | `list(string)` | n/a | yes |
| <a name="input_internal_repo"></a> [internal\_repo](#input\_internal\_repo) | The internal GitHub repository to create | <pre>object({<br>    name          = string<br>    org           = string<br>    topics        = optional(list(string), [])<br>    collaborators = optional(map(string), {})<br>    admin_teams   = optional(list(string), [])<br>  })</pre> | n/a | yes |
| <a name="input_public_repo"></a> [public\_repo](#input\_public\_repo) | The public GitHub repository to import | <pre>object({<br>    clone_url      = string<br>    default_branch = string<br>  })</pre> | n/a | yes |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | Enable GitHub vulnerability alerts | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_repo"></a> [internal\_repo](#output\_internal\_repo) | n/a |
<!-- END_TF_DOCS -->