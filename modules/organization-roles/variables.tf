variable "gcp_organization_id" {
  description = "The GCP organization ID. Must match the organization module."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{1,}$", var.gcp_organization_id))
    error_message = "The GCP organization ID must be numeric."
  }
}

variable "upwind_organization_id" {
  description = "The identifier of the Upwind organization to integrate with. Must match the organization module. Used only to derive custom role IDs."
  type        = string

  validation {
    condition     = can(regex("^org_[a-zA-Z0-9]{1,}$", var.upwind_organization_id))
    error_message = "The Upwind organization ID must start with 'org_' followed by alphanumeric characters."
  }
}

variable "resource_suffix" {
  description = "The suffix appended to custom role IDs. Must match the organization module, including an empty suffix."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{0,10}$", var.resource_suffix))
    error_message = "The resource suffix must be alphanumeric and cannot exceed 10 characters."
  }
}

variable "upwind_management_sa_email" {
  description = "Email of the Upwind management service account created by the organization module."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam\\.gserviceaccount\\.com$", var.upwind_management_sa_email))
    error_message = "upwind_management_sa_email must be a Google Cloud service account email."
  }
}

variable "enable_cloudscanners" {
  description = "Create the CloudScanner organization roles and bindings. Must match enable_cloudscanners on the organization module."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_cloudscanners || (var.cloudscanner_sa_email != "" && var.cloudscanner_scaler_sa_email != "")
    error_message = "cloudscanner_sa_email and cloudscanner_scaler_sa_email are required when enable_cloudscanners is true."
  }
}

variable "enable_dspm_scanning" {
  description = "Include storage object read permissions on the CloudScanner operations role. Must match the organization module. Only applies when enable_cloudscanners is true."
  type        = bool
  default     = false
}

variable "enable_snapshot_act_as" {
  description = "Append iam.serviceAccounts.actAs to the CloudScanner operations role so snapshot jobs can act as the target project's default Compute Engine service account. Must match the organization module."
  type        = bool
  default     = true
}

variable "cloudscanner_sa_email" {
  description = "Email of the CloudScanner service account created by the organization module. Required when enable_cloudscanners is true."
  type        = string
  default     = ""

  validation {
    condition     = var.cloudscanner_sa_email == "" || can(regex("^[a-z0-9-]+@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam\\.gserviceaccount\\.com$", var.cloudscanner_sa_email))
    error_message = "cloudscanner_sa_email must be empty or a Google Cloud service account email."
  }
}

variable "cloudscanner_scaler_sa_email" {
  description = "Email of the CloudScanner scaler service account created by the organization module. Required when enable_cloudscanners is true."
  type        = string
  default     = ""

  validation {
    condition     = var.cloudscanner_scaler_sa_email == "" || can(regex("^[a-z0-9-]+@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam\\.gserviceaccount\\.com$", var.cloudscanner_scaler_sa_email))
    error_message = "cloudscanner_scaler_sa_email must be empty or a Google Cloud service account email."
  }
}
