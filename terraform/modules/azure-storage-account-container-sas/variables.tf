variable "storage_account_name" {
  description = "Name of the Azure Storage Account"
  type        = string
  default     = "terraformpipeline"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Location of Azure resources"
  type        = string
  default     = "northeurope"
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}

variable "container_name" {
  description = "Name of the Azure Container"
  type        = string
  default     = "terraform-state"
}

# variable "sas_token_start" {
#   description = "Start time of SAS token (ISO 8601 format). Example: 2023-02-16T05:29:53Z"
#   type = string
#   default = timestamp()
# }

# variable "sas_token_end" {
#   description = "Start time of SAS token (ISO 8601 format). Example: 2025-02-16T05:29:53Z"
#   type = string
#   default = timeadd(timestamp(), "17520h")
# }