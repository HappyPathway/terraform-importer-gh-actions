data "github_repository" "public_repo" {
  provider  = github.public_repo
  full_name = "${var.public_repo.org}/${var.public_repo.name}"
}

data "github_ref" "ref" {
  provider   = github.public_repo
  owner      = var.public_repo.org
  repository = var.public_repo.name
  ref        = "heads/${data.github_repository.public_repo.default_branch != null ? data.github_repository.public_repo.default_branch : "main"}"
}

# Get all files from the source repository
data "github_tree" "source_tree" {
  provider   = github.public_repo
  repository = var.public_repo.name
  recursive  = true
  tree_sha   = data.github_ref.ref.sha
}

module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = data.github_repository.public_repo.description
  repo_org                = var.internal_repo.org
  name                    = var.internal_repo.name
  github_repo_topics = concat([
    "github-actions"
    ],
    data.github_repository.public_repo.topics != null ?
    length(data.github_repository.public_repo.topics) > 0 ? data.github_repository.public_repo.topics : []
    : []
  )
  force_name           = true
  github_is_private    = false
  create_codeowners    = false
  enforce_prs         = false
  collaborators       = var.internal_repo.collaborators
  admin_teams        = var.internal_repo.admin_teams
  github_org_teams   = var.github_org_teams
  providers = {
    github = github.internal_repo
  }
  vulnerability_alerts = var.vulnerability_alerts
  archive_on_destroy  = false
  github_default_branch = var.source_default_branch
}

resource "terraform_data" "replacement" {
  input = module.internal_github_actions.github_repo.node_id
}

# Copy each file from source to destination
resource "github_repository_file" "sync_files" {
  provider = github.internal_repo
  for_each = { for item in data.github_tree.source_tree.entries : item.path => item if item.type == "blob" }

  repository          = module.internal_github_actions.github_repo.name
  branch             = module.internal_github_actions.github_repo.default_branch
  file               = each.value.path
  content            = data.github_repository_file.source_files[each.key].content
  commit_message     = "Sync from ${var.public_repo.org}/${var.public_repo.name}"
  commit_author      = "Terraform"
  commit_email       = "terraform@example.com"
  overwrite_on_create = true

  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}

# Get content of each file from source repository
data "github_repository_file" "source_files" {
  provider   = github.public_repo
  for_each   = { for item in data.github_tree.source_tree.entries : item.path => item if item.type == "blob" }
  
  repository = var.public_repo.name
  branch     = data.github_repository.public_repo.default_branch
  file       = each.value.path
}

output "public_repo" {
  value = data.github_repository.public_repo
}

output "internal_repo" {
  value = module.internal_github_actions.github_repo
}
