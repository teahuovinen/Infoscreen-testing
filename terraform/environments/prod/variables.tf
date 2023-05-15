variable "project_name" {
  description = "Name of your project (use CamelCase, no spaces). Max characters 19."
  type        = string
  validation {
    condition     = length(var.project_name) < 20 && length(var.project_name) != 0
    error_message = "Max characters 19. Can't be empty."
  }
}

variable "lvm_size" {
  description = "Size of the Linux Virtual Machine"
  type        = string
  default     = "Standard_B1s"
}

variable "environment" {
  description = "Type of environment."
  type        = string
}

variable "location" {
  description = "Location of Azure resources"
  type        = string
  default     = "northeurope"
}

variable "lvm_custom_data_path_to_file" {
  description = "Path to file for custom_data field in Linux Virtual Machine"
  type        = string
}

variable "nsg_ssh_security_rule_source_address" {
  description = "List of IP adresses that can SSH into VM"
  type        = list(any)
}

variable "nsg_80_security_rule_source_address" {
  description = "List of IP adresses that are allowed to connect VM via port 80"
  type        = list(any)
}

locals {
  mandatory_tags = {
    managed_by   = "terraform"
    project_name = var.project_name
    environment  = var.environment
  }
}