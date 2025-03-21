
output "public_repo" {
  value = data.github_repository.public_repo
}

output "internal_repo" {
  value = module.internal_github_actions.github_repo
}

output source_ref {
    value = data.github_ref.ref
}