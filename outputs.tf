output "public_repo" {
  value = {
    name = var.public_repo.name
    org = var.public_repo.org
    description = data.external.public_repo.result.description
    default_branch = data.external.public_repo.result.default_branch
    topics = try(jsondecode(jsonencode(data.external.public_repo.result.topics)), [])
    id = data.external.public_repo.result.id
  }
}

output "internal_repo" {
  value = module.internal_github_actions.github_repo
}
