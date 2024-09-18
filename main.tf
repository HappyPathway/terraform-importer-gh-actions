data "github_repository" "public_repo" {
  full_name = "${var.public_repo.owner}/${var.public_repo.name}"
}

data "github_ref" "ref" {
  owner      = var.public_repo.owner
  repository = var.public_repo.name
  ref        = "heads/${data.github_repository.public_repo.default_branch != null ? data.github_repository.public_repo.default_branch : "main"}"
}

module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = "Imported External Github Actions Repository"
  repo_org                = var.repo_org
  name                    = var.repo_name
  github_repo_topics = concat([
    "github-actions"
  ], var.repo_topics)
  force_name        = true
  github_is_private = false
  create_codeowners = false
  enforce_prs       = false
  collaborators     = var.collaborators
  admin_teams       = var.admin_teams
}

resource "local_file" "script" {
  filename = "${path.module}/import.sh"
  content = templatefile("${path.module}/script.tpl", {
    repo_path               = local.repo_path
    public_clone_url        = data.github_repository.public_repo.http_clone_url
    internal_clone_url      = module.internal_github_actions.github_repo.ssh_clone_url
    internal_default_branch = module.internal_github_actions.github_repo.default_branch
    public_default_branch   = data.github_repository.public_repo.default_branch
    cur_dir                 = path.module
  })
  depends_on = [data.github_repository.public_repo]
}

resource "null_resource" "git_import" {

  triggers = {
    sha = data.github_ref.ref.sha
  }

  provisioner "local-exec" {
    command = local_file.script.filename
  }

  depends_on = [local_file.script]
}

output "public_repo" {
  value = data.github_repository.public_repo
}

output "internal_repo" {
  value = module.internal_github_actions.github_repo
}
