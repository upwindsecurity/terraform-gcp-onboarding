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

output "organization_iam_requirements" {
  description = "The organization-level custom roles and grants this deployment needs, created by the module unless manage_organization_iam is false. custom_roles is keyed by role ID; bindings is keyed by a stable name, one additive grant per role and member, and is the source of truth (conditions appear only there); by_service_account is a per-member summary for review."
  value       = local.organization_iam_requirements
}
