### Folder-Level Cloud Logs Roles

# Read access to log sinks and monitoring time series for audit logs integrations
resource "google_organization_iam_custom_role" "upwind_cloudlogs_reader_role" {
  count       = var.enable_cloudlogs ? 1 : 0
  org_id      = var.gcp_organization_id
  role_id     = "UpwindCloudLogsReader_${local.resource_suffix_underscore}"
  title       = "upwind-role-${local.resource_suffix_hyphen}-cloudlogs-reader"
  description = "Read access to log sinks and monitoring time series for Upwind cloud logs"
  permissions = module.iam.cloudlogs_read_permissions
}

# Grant the cloud logs reader role to the Cloud Logs SA on each target folder
resource "google_folder_iam_member" "upwind_cloudlogs_sa_reader_role_member" {
  for_each = var.enable_cloudlogs ? toset(var.target_folder_ids) : toset([])

  folder = each.value
  role   = google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].id
  member = "serviceAccount:${module.iam.cloudlogs_sa_email}"
}
