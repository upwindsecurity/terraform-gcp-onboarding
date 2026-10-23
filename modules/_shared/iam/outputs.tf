### Service Accounts

output "upwind_management_sa" {
  description = "The Upwind Management Service Account details."
  value       = google_service_account.upwind_management_sa
}

output "cloudscanner_sa" {
  description = "The Cloudscanner Service Account details."
  value       = local.deploy_cloudscanners ? google_service_account.cloudscanner_sa[0] : null
}

output "cloudscanner_identity_email" {
  description = "The email of the account CloudScanners act as in the customer's organization: the management service account in SaaS mode, else the CloudScanner service account."
  value       = local.cloudscanner_identity_email
}

output "cloudscanner_scaler_sa" {
  description = "The Cloudscanner Scaler Service Account details."
  value       = local.deploy_cloudscanners ? google_service_account.cloudscanner_scaler_sa[0] : null
}

### IAM Custom Roles

output "google_project_iam_custom_role" {
  description = "The custom IAM roles created at the project level."
  value = {
    upwind_management_sa_cloudscanner_deployment_role = local.deploy_cloudscanners ? google_project_iam_custom_role.upwind_management_sa_cloudscanner_deployment_role[0] : null
    cloudscanner_basic_role                           = local.deploy_cloudscanners ? google_project_iam_custom_role.cloudscanner_basic_role[0] : null
    cloudscanner_scaler_role                          = local.deploy_cloudscanners ? google_project_iam_custom_role.cloudscanner_scaler_role[0] : null
    cloudscanner_secret_access_role                   = local.deploy_cloudscanners ? google_project_iam_custom_role.cloudscanner_secret_access_role[0] : null
    cloudscanner_instance_template_mgmt_role          = local.deploy_cloudscanners ? google_project_iam_custom_role.cloudscanner_instance_template_mgmt_role[0] : null
    cloudscanner_instance_template_test_creation_role = local.deploy_cloudscanners ? google_project_iam_custom_role.cloudscanner_instance_template_test_creation_role[0] : null
    compute_service_agent_minimal                     = local.deploy_cloudscanners ? google_project_iam_custom_role.compute_service_agent_minimal[0] : null
    disk_writer                                       = local.deploy_cloudscanners ? google_project_iam_custom_role.disk_writer[0] : null
  }
}

### IAM Members

output "google_project_iam_member" {
  description = "The IAM role bindings at the project level."
  value = {
    upwind_management_sa_cloudscanner_deployment_role_member = local.deploy_cloudscanners ? google_project_iam_member.upwind_management_sa_cloudscanner_deployment_role_member[0] : null
    upwind_management_sa_secret_access_role_member           = local.deploy_cloudscanners ? google_project_iam_member.upwind_management_sa_secret_access_role_member[0] : null
    compute_service_agent_minimal                            = local.deploy_cloudscanners ? google_project_iam_member.compute_service_agent_minimal[0] : null
    cloudscanner_instance_template_mgmt_member               = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_instance_template_mgmt_member[0] : null
    cloudscanner_instance_template_test_creation_member      = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_instance_template_test_creation_member[0] : null
    cloudscanner_sa_basic_role_member                        = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_sa_basic_role_member[0] : null
    cloudscanner_sa_scaler_role_member                       = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_sa_scaler_role_member[0] : null
    cloudscanner_scaler_sa_run_invoker                       = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_scaler_sa_run_invoker[0] : null
    cloudscanner_scaler_sa_scaler_role_member                = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_scaler_sa_scaler_role_member[0] : null
    cloudscanner_scaler_secret_access_scaler_role_member     = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_scaler_secret_access_scaler_role_member[0] : null
    cloudscanner_secret_access_role_member                   = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_secret_access_role_member[0] : null
  }
}

output "google_project_iam_member_disk_writer" {
  description = "The IAM member bindings for disk writer role."
  value = {
    cloudscanner_sa_disk_writer_role_member        = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_sa_disk_writer_role_member[0] : null
    cloudscanner_scaler_sa_disk_writer_role_member = local.deploy_cloudscanners ? google_project_iam_member.cloudscanner_scaler_sa_disk_writer_role_member[0] : null
  }
}

output "google_service_account_iam_binding" {
  description = "The IAM bindings for service accounts."
  value = {
    scaler_and_compute_can_use_cloudscanner = local.deploy_cloudscanners ? google_service_account_iam_binding.scaler_and_compute_can_use_cloudscanner[0] : null
    management_can_impersonate_scanner      = local.deploy_cloudscanners ? google_service_account_iam_member.management_can_impersonate_scanner[0] : null
    management_can_impersonate_scaler       = local.deploy_cloudscanners ? google_service_account_iam_member.management_can_impersonate_scaler[0] : null
    scanner_can_impersonate_scaler          = local.deploy_cloudscanners ? google_service_account_iam_member.scanner_can_impersonate_scaler[0] : null
    scaler_can_impersonate_scanner          = local.deploy_cloudscanners ? google_service_account_iam_member.scaler_can_impersonate_scanner[0] : null
    cloudscheduler_can_impersonate_scaler   = local.deploy_cloudscanners ? google_service_account_iam_member.cloudscheduler_can_impersonate_scaler[0] : null
  }
}

### Secrets

output "google_secret_manager_secret" {
  description = "The secrets referenced in Secret Manager, whether created by this module or supplied by the customer as pre-existing secrets."
  value = {
    upwind_client_id      = google_secret_manager_secret.upwind_client_id
    upwind_client_secret  = local.upwind_client_secret_ref
    scanner_client_id     = local.deploy_cloudscanners ? google_secret_manager_secret.scanner_client_id : null
    scanner_client_secret = local.scanner_client_secret_ref
    upwind_configuration  = google_secret_manager_secret.upwind_configuration
  }
}

output "upwind_configuration_payload" {
  description = "JSON written to the upwind-configuration secret. Add it as a version yourself when create_secret_versions is false."
  value       = jsonencode(local.upwind_configuration_payload)
}

### Workload Identity Federation

output "google_iam_workload_identity_pool" {
  description = "The Workload Identity Pool created."
  value       = google_iam_workload_identity_pool.main
}

output "google_iam_workload_identity_pool_provider" {
  description = "The Workload Identity Pool Provider created."
  value       = google_iam_workload_identity_pool_provider.aws
}

output "google_iam_workload_identity_pool_provider_saas" {
  description = "The Workload Identity Pool Provider for Upwind-hosted CloudScanners, when is_saas is true."
  value       = var.is_saas ? google_iam_workload_identity_pool_provider.gcp[0] : null
}

### Permissions

output "storage_read_permissions" {
  description = "List of IAM permissions for storage read access."
  value       = var.storage_read_permissions
}

output "iam_read_role_permissions" {
  description = "List of IAM permissions for read-only access role."
  value       = var.iam_read_role_permissions
}

output "organization_iam_read_permissions" {
  description = "List of IAM permissions for reading the organization IAM policy."
  value       = var.organization_iam_read_permissions
}

output "snapshot_reader_permissions" {
  description = "List of IAM permissions for snapshot reader role."
  value       = var.snapshot_reader_permissions
}

output "snapshot_creator_permissions" {
  description = "List of IAM permissions for snapshot creator role."
  value = concat(
    var.snapshot_creator_permissions,
    var.enable_snapshot_act_as && !var.is_saas ? ["iam.serviceAccounts.actAs"] : [],
  )
}

output "snapshot_deleter_permissions" {
  description = "List of IAM permissions for snapshot deleter role."
  value       = var.snapshot_deleter_permissions
}

output "storage_object_reader_permissions" {
  description = "List of IAM permissions for storage object reader role."
  value       = var.storage_object_reader_permissions
}

output "cloud_run_permissions" {
  description = "List of IAM permissions for Cloud Run role."
  value       = var.cloud_run_permissions
}

### Labels

output "labels" {
  description = "Labels applied to all resources."
  value       = var.labels
}

output "default_labels" {
  description = "Default labels applied to all resources (can be overridden)."
  value       = var.default_labels
}
