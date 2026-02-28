variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "southindia"
}

variable "project_name" {
  description = "Project name — used as prefix for all resource names"
  type        = string
  default     = "selfhealing"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "github_token" {
  description = "GitHub Personal Access Token for healing engine — stored in Key Vault"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repo in format sarthakdixit/self-healing-pipeline"
  type        = string
}

variable "github_owner" {
  description = "GitHub username or org name"
  type        = string
}