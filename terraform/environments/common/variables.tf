variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "project_name" {
  description = "Name of your project (use CamelCase, no spaces). Max characters 19."
  type        = string
  validation {
    condition     = length(var.project_name) < 20 && length(var.project_name) != 0
    error_message = "Max characters 19. Can't be empty."
  }
}

variable "environment" {
  description = "Type of environment."
  type        = string
  default     = "backend"
}

variable "location" {
  description = "Location of Azure resources"
  type        = string
  default     = "northeurope"
}


locals {
  mandatory_tags = {
    managed_by   = "terraform"
    project_name = var.project_name
    environment  = var.environment
  }
}