# Use external data source to run the Python script
data "external" "public_repo" {
  program = [
    "${path.module}/fetch_repo.py", 
    "--org", var.public_repo.org,
    "--name", var.public_repo.name, 
    "--action", "repo"]
}

locals {
  # Extract the default branch from the external data source output
  default_branch = coalesce(var.public_repo.default_branch, data.external.public_repo.result.default_branch)
}

data "external" "branch_sha" {
  program = ["${path.module}/fetch_repo.py", 
  "--org", var.public_repo.org, 
  "--name", var.public_repo.name, 
  "--action", "tree", 
  "--branch", local.default_branch]
  depends_on = [data.external.public_repo]
}

# Extract file tree from the external data source output
locals {
  file_entries = jsondecode(jsonencode(data.external.branch_sha.result))
}

module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = data.external.public_repo.result.description
  repo_org                = var.internal_repo.org
  name                    = var.internal_repo.name
  github_repo_topics = concat([
    "github-actions"
    ],
    try(jsondecode(jsonencode(data.external.public_repo.result.topics)), [])
  )
  force_name           = true
  github_is_private    = false
  create_codeowners    = false
  enforce_prs         = false
  collaborators       = var.internal_repo.collaborators
  admin_teams        = var.internal_repo.admin_teams
  github_org_teams   = var.github_org_teams
  vulnerability_alerts = var.vulnerability_alerts
  archive_on_destroy  = false
  github_default_branch = var.source_default_branch
}

resource "terraform_data" "replacement" {
  input = { for item in local.file_entries : item.path => item if item.type == "blob" }
}

# Copy each file from source to destination
resource "github_repository_file" "sync_files" {
  for_each = { for item in local.file_entries : item.path => item if item.type == "blob" }

  repository          = module.internal_github_actions.github_repo.name
  branch              = module.internal_github_actions.github_repo.default_branch
  file                = each.value.path
  commit_message      = "Sync from ${var.public_repo.org}/${var.public_repo.name}"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
  content = base64decode(data.external.file_content[each.key].result.content)
  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}

# Get content of each file from source repository using Python script
data "external" "file_content" {
  for_each = { for item in local.file_entries : item.path => item if item.type == "blob" }
  
  program = [
    "${path.module}/fetch_repo.py", 
    "--org", var.public_repo.org, 
    "--name", var.public_repo.name, 
    "--action", "file", 
    "--path", each.key, 
    "--branch", local.default_branch
  ]
  depends_on = [data.external.public_repo]
}
