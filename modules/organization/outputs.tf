output "upwind_management_service_account_name" {
  description = "The name of the Upwind Management Service Account."
  value       = module.iam.upwind_management_sa.name
}

output "upwind_management_service_account_display_name" {
  description = "The display name of the Upwind Management Service Account."
  value       = module.iam.upwind_management_sa.display_name
}

output "upwind_management_service_account_email" {
  description = "The email address of the Upwind Management Service Account."
  value       = module.iam.upwind_management_sa.email
}

output "upwind_management_service_account_unique_id" {
  description = "The unique ID of the Upwind Management Service Account."
  value       = module.iam.upwind_management_sa.unique_id
}

output "upwind_management_service_account_project" {
  description = "The project ID of the Upwind Management Service Account."
  value       = module.iam.upwind_management_sa.project
}

output "upwind_workload_identity_pool_id" {
  description = "The ID of the Upwind Workload Identity Pool."
  value       = module.iam.google_iam_workload_identity_pool.workload_identity_pool_id
}

output "workload_identity_provider_name" {
  description = "Full path name of the workload identity pool provider"
  value       = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${module.iam.google_iam_workload_identity_pool.workload_identity_pool_id}/providers/${module.iam.google_iam_workload_identity_pool_provider.workload_identity_pool_provider_id}"
}

output "upwind_configuration_payload" {
  description = "JSON written to the upwind-configuration secret. Add it as a version yourself when create_secret_versions is false."
  value       = module.iam.upwind_configuration_payload
}

output "upwind_cloudscanner_service_account_email" {
  description = "Email of the CloudScanner service account. Null when cloud scanners are disabled."
  value       = try(module.iam.cloudscanner_sa.email, null)
}

output "upwind_cloudscanner_scaler_service_account_email" {
  description = "Email of the CloudScanner scaler service account. Null when cloud scanners are disabled."
  value       = try(module.iam.cloudscanner_scaler_sa.email, null)
}

output "organization_iam" {
  description = "Organization roles this integration requires. When skip_organization_roles_creation is false, this module creates them. When true, pass these values to modules/organization-roles."
  value = {
    managed_by_this_module                = !var.skip_organization_roles_creation
    gcp_organization_id                   = var.gcp_organization_id
    upwind_organization_id                = var.upwind_organization_id
    resource_suffix                       = var.resource_suffix
    enable_cloudscanners                  = var.enable_cloudscanners
    enable_dspm_scanning                  = var.enable_dspm_scanning
    enable_snapshot_act_as                = var.enable_snapshot_act_as
    upwind_management_sa_email            = module.iam.upwind_management_sa.email
    cloudscanner_sa_email                 = try(module.iam.cloudscanner_sa.email, null)
    cloudscanner_scaler_sa_email          = try(module.iam.cloudscanner_scaler_sa.email, null)
    operations_role_id                    = "UpwindOperations_${local.resource_suffix_underscore}"
    cloudscanner_operations_role_id       = var.enable_cloudscanners ? "CloudScannerOperationsRole_${local.resource_suffix_underscore}" : null
    cloudscanner_snapshot_deleter_role_id = var.enable_cloudscanners ? "CloudScannerSnapshotDeleter_${local.resource_suffix_underscore}" : null
    cloudscanner_object_reader_role_id    = var.enable_cloudscanners && var.enable_dspm_scanning ? "CloudScannerObjectReader_${local.resource_suffix_underscore}" : null
  }
}
