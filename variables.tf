variable "internal_repo" {
  description = "The internal GitHub repository to create"
  type = object({
    name          = string
    org           = string
    topics        = optional(list(string), [])
    collaborators = optional(map(string), {})
    admin_teams   = optional(list(string), [])
  })
}

variable "public_repo" {
  description = "The public GitHub repository to import"
  type = object({
    clone_url      = string
    default_branch = string
  })
}

variable "github_org_teams" {
  description = "The GitHub organization teams to add to the repository"
  type        = list(any)
  default     = []
}

variable "vulnerability_alerts" {
  description = "Enable GitHub vulnerability alerts"
  type        = bool
  default     = true
}

variable "github_repo_topics" {
  type = list(string)
}

variable source_default_branch {
  default = "main"
  type   = string
}

variable "force" {
  type    = bool
  default = false
}
