module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = var.internal_repo.name
  repo_org                = var.internal_repo.org
  name                    = var.internal_repo.name
  github_repo_topics      = var.internal_repo.topics
  force_name              = true
  github_is_private       = false
  create_codeowners       = false
  enforce_prs             = false
  collaborators           = var.internal_repo.collaborators
  # yes, this is a bug, but it's a bug in the module, not the code
  admin_teams          = var.internal_repo.admin_teams
  github_org_teams     = var.github_org_teams
  vulnerability_alerts = var.vulnerability_alerts
  archive_on_destroy   = false
  github_default_branch = var.source_default_branch
}

locals {
  script = templatefile("${path.module}/script.tpl", {
    repo_path               = local.repo_path
    public_clone_url        = var.public_repo.clone_url
    internal_clone_url      = module.internal_github_actions.github_repo.ssh_clone_url
    internal_default_branch = module.internal_github_actions.github_repo.default_branch
    public_default_branch   = var.public_repo.default_branch
    cur_dir                 = path.module
  })
}

provider "github" {
  alias = "public"
}

data "github_repository" "public_repo" {
  count = var.public_repo.name == null ? 0 : 1
  provider  = github.public
  full_name = "${var.public_repo.org}/${var.public_repo.name}"
}

data "github_ref" "public_sha" {
  count = var.public_repo.name == null ? 0 : 1
  provider   = github.public
  owner      = var.public_repo.org
  repository = var.public_repo.name
  ref        = "heads/${data.github_repository.public_repo[0].default_branch}"
}


resource "terraform_data" "replacement" {
  input = module.internal_github_actions.github_repo.node_id
}

resource "null_resource" "git_import" {
  triggers = {
    sha = var.public_repo.name == null ? timestamp() : data.github_ref.public_sha[0].sha
  }
  provisioner "local-exec" {
    command = "echo '${local.script}' > ${path.module}/import.sh"
  }

  provisioner "local-exec" {
    command = "chmod +x ${path.module}/import.sh"
  }

  provisioner "local-exec" {
    command = "${path.module}/import.sh"
  }

  depends_on = [
    module.internal_github_actions
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}

output "internal_repo" {
  value = module.internal_github_actions.github_repo
}
