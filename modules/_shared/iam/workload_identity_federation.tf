locals {
  # WIF pool/provider IDs are limited to 32 characters.
  wif_pool_timestamp = formatdate("YYYYMMDD-hhmm", timestamp())
  wif_pool_id        = "${local.org_id_sanitized}-${local.wif_pool_timestamp}"
  wif_provider_id    = "${local.org_id_sanitized}-aws"
}

# This pool needs a timestamp, as GCP uses soft-deletion for WIF pools
# This allows us to create a new pool in an apply-destroy-apply cycle
resource "google_iam_workload_identity_pool" "main" {
  workload_identity_pool_id = local.wif_pool_id
  project                   = var.workload_identity_pool_project == "" ? local.project : var.workload_identity_pool_project
  display_name              = "Upwind Identity Pool"
  description               = "Identity pool for external Upwind workloads"
  disabled                  = false

  lifecycle {
    precondition {
      condition     = length(local.wif_pool_id) <= 32
      error_message = "Workload identity pool ID '${local.wif_pool_id}' exceeds the 32 character limit. The Upwind organization ID is too long for WIF pool naming."
    }

    # Ignore changes to the pool ID after creation
    # This prevents recreation on subsequent applies while allowing initial creation with timestamp
    ignore_changes = [workload_identity_pool_id]

    # Create before destroy to handle soft deletion gracefully
    create_before_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "aws" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = local.wif_provider_id
  project                            = var.workload_identity_pool_project == "" ? local.project : var.workload_identity_pool_project
  display_name                       = "Upwind AWS Provider"
  description                        = "Identity pool provider for Upwind AWS workloads"

  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.session"     = "assertion.arn.extract('assumed-role/upwind-gcp/{session}')"
  }

  # Requires the caller to assume the 'upwind-gcp' role in the trusted account
  # Session name must equal this org's ID
  attribute_condition = "assertion.account == '${var.workload_identity_trusted_account}' && assertion.arn == 'arn:aws:sts::${var.workload_identity_trusted_account}:assumed-role/upwind-gcp/${var.upwind_organization_id}'"

  aws {
    account_id = var.workload_identity_trusted_account
  }

  lifecycle {
    precondition {
      condition     = length(local.wif_provider_id) <= 32
      error_message = "Workload identity provider ID '${local.wif_provider_id}' exceeds the 32 character limit. The Upwind organization ID is too long for WIF provider naming."
    }
    # Ignore changes after creation to prevent unintentional WIF credentials invalidations
    ignore_changes = [workload_identity_pool_provider_id]
  }
}

# Management SA access
resource "google_service_account_iam_member" "management_workload_identity" {
  service_account_id = google_service_account.upwind_management_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.aws_account/${var.workload_identity_trusted_account}"
  depends_on         = [google_service_account.upwind_management_sa]
}

# Service Account Token Creator for impersonation
resource "google_service_account_iam_member" "management_token_creator" {
  service_account_id = google_service_account.upwind_management_sa.id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.aws_account/${var.workload_identity_trusted_account}"
  depends_on         = [google_service_account.upwind_management_sa]
}

# Cloudscanner SA access
resource "google_service_account_iam_member" "cloudscanner_workload_identity" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_sa[0].id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.aws_account/${var.workload_identity_trusted_account}"
  depends_on         = [google_service_account.cloudscanner_sa[0]]
}

# Service Account Token Creator for cloudscanner impersonation
resource "google_service_account_iam_member" "cloudscanner_token_creator" {
  count              = local.deploy_cloudscanners ? 1 : 0
  service_account_id = google_service_account.cloudscanner_sa[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.aws_account/${var.workload_identity_trusted_account}"
  depends_on         = [google_service_account.cloudscanner_sa[0]]
}

# SaaS mode: Upwind-hosted CloudScanners authenticate with a Google ID token for an Upwind service account.
# They are granted access through this pool rather than directly, since domain-restricted sharing
# (constraints/iam.allowedPolicyMemberDomains) rejects IAM grants to principals outside the customer's org.
# The provider ID is fixed because the hosted CloudScanner worker derives it rather than reading it.
resource "google_iam_workload_identity_pool_provider" "gcp" {
  count                              = var.is_saas ? 1 : 0
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = "upwind-saas-gcp"
  project                            = google_iam_workload_identity_pool.main.project
  display_name                       = "Upwind GCP Provider"
  description                        = "Identity pool provider for Upwind-hosted CloudScanners"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  # Any service account can mint an ID token for this issuer with an arbitrary audience,
  # so the audience alone is not a boundary: only the Upwind service account's tokens are accepted
  attribute_condition = "assertion.sub == '${var.workload_identity_saas_subject}'"

  oidc {
    issuer_uri = "https://accounts.google.com"
  }
}

# Management SA access for the Upwind-hosted scanner, pinned to its subject
resource "google_service_account_iam_member" "cloudscanner_saas_workload_identity" {
  count              = var.is_saas ? 1 : 0
  service_account_id = google_service_account.upwind_management_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/subject/${var.workload_identity_saas_subject}"
}
