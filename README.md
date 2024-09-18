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
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |
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
| [github_ref.ref](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/ref) | data source |
| [github_repository.public_repo](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_teams"></a> [admin\_teams](#input\_admin\_teams) | List of admin teams for the GitHub repository | `list(string)` | `[]` | no |
| <a name="input_collaborators"></a> [collaborators](#input\_collaborators) | List of collaborators to add to the GitHub repository | `map(string)` | `{}` | no |
| <a name="input_git_repo_path"></a> [git\_repo\_path](#input\_git\_repo\_path) | The local path where the Git repository will be cloned | `string` | n/a | yes |
| <a name="input_public_repo"></a> [public\_repo](#input\_public\_repo) | n/a | <pre>object({<br>    owner = string,<br>    name  = string<br>  })</pre> | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | The name of the GitHub repository | `string` | n/a | yes |
| <a name="input_repo_org"></a> [repo\_org](#input\_repo\_org) | The GitHub organization for the repository | `string` | n/a | yes |
| <a name="input_repo_topics"></a> [repo\_topics](#input\_repo\_topics) | Additional topics to add to the GitHub repository | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_repo"></a> [internal\_repo](#output\_internal\_repo) | n/a |
| <a name="output_public_repo"></a> [public\_repo](#output\_public\_repo) | n/a |
<!-- END_TF_DOCS -->