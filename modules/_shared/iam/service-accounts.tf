### IAM Service Accounts

# account_id is limited to 30 characters, so on renaming this will need some consideration
# temporary name prefix of test- to be updated to upwind-

# The service account to configure all automatic deployment of Cloudscanners
# This is the service account that we will authenticate to using Workload Identity Federation
resource "google_service_account" "upwind_management_sa" {
  project      = var.upwind_orchestrator_project
  account_id   = format("upwind-mgmt-%s", local.resource_suffix_hyphen)
  display_name = var.google_service_account_display_name
  description  = "Service account with access to the organisation"

  lifecycle {
    precondition {
      condition     = length(local.resource_suffix_hyphen) <= 16
      error_message = "Service account ID cannot exceed 30 characters."
    }
  }
}

### CloudScanner Service Accounts

locals {
  # The account CloudScanners act as in the customer's organization. In SaaS mode that is the
  # management account, because the hosted worker impersonates the account its stored credential names.
  cloudscanner_identity_email = !var.enable_cloudscanners ? null : (
    var.is_saas ? google_service_account.upwind_management_sa.email : google_service_account.cloudscanner_sa[0].email
  )
}

# The main service account for the CloudScanner to use across all projects
# This service account will be attached to the CloudScanner Worker Instances
resource "google_service_account" "cloudscanner_sa" {
  count        = local.deploy_cloudscanners ? 1 : 0
  project      = var.upwind_orchestrator_project
  account_id   = format("upwind-cs-%s", local.resource_suffix_hyphen)
  display_name = "Upwind CloudScanner Cross Account Service Account"
  description  = "Service account used by CloudScanners to perform scans across multiple projects"

  lifecycle {
    precondition {
      condition     = length(local.resource_suffix_hyphen) <= 16
      error_message = "Service account ID cannot exceed 30 characters."
    }
  }
}

# The service account which will be used to run the scaler function
# This service account will be used to scale the CloudScanner Instance Groups via Cloud Run
resource "google_service_account" "cloudscanner_scaler_sa" {
  count        = local.deploy_cloudscanners ? 1 : 0
  project      = var.upwind_orchestrator_project
  account_id   = format("upwind-scaler-%s", local.resource_suffix_hyphen)
  display_name = "Upwind CloudScanner Scaler Service Account"
  description  = "Service account used to manage the scaling of CloudScanners"

  lifecycle {
    precondition {
      condition     = length(local.resource_suffix_hyphen) <= 16
      error_message = "Service account ID cannot exceed 30 characters."
    }
  }
}

# Allow scaler to impersonate scanner SA AND allow Compute Engine service to use scanner SA for VM operations
resource "google_service_account_iam_binding" "scaler_and_compute_can_use_cloudscanner" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_sa[0].id
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.cloudscanner_scaler_sa[0].email}",
    "serviceAccount:${data.google_project.current.number}@cloudservices.gserviceaccount.com"
  ]
}

# Allow management SA to create tokens for scanner SA
resource "google_service_account_iam_member" "management_can_impersonate_scanner" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_sa[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.upwind_management_sa.email}"
}

# Allow management SA to create tokens for scaler SA
resource "google_service_account_iam_member" "management_can_impersonate_scaler" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_scaler_sa[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.upwind_management_sa.email}"
}

# Allow scanner SA to create tokens for scaler SA
resource "google_service_account_iam_member" "scanner_can_impersonate_scaler" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_scaler_sa[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.cloudscanner_sa[0].email}"
}

# Allow scaler SA to create tokens for scanner SA
resource "google_service_account_iam_member" "scaler_can_impersonate_scanner" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_sa[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.cloudscanner_scaler_sa[0].email}"
}

# Allow Cloud Scheduler to impersonate scaler SA
resource "google_service_account_iam_member" "cloudscheduler_can_impersonate_scaler" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_scaler_sa[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloudscheduler.iam.gserviceaccount.com"
}
