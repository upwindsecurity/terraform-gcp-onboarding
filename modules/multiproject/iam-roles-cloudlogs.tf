### Project-Scoped Cloud Logs Roles

# Read access to log sinks and monitoring time series for audit logs integrations (per project)
resource "google_project_iam_custom_role" "upwind_cloudlogs_reader_role" {
  for_each = var.enable_cloudlogs ? toset(var.target_project_ids) : toset([])

  project     = each.value
  role_id     = "UpwindCloudLogsReader_${local.resource_suffix_underscore}"
  title       = "upwind-role-${local.resource_suffix_hyphen}-cloudlogs-reader"
  description = "Read access to log sinks and monitoring time series for Upwind cloud logs"
  permissions = module.iam.cloudlogs_read_permissions
}

# Grant the cloud logs reader role to the Cloud Logs SA on each target project
resource "google_project_iam_member" "upwind_cloudlogs_sa_reader_role_member" {
  for_each = var.enable_cloudlogs ? toset(var.target_project_ids) : toset([])

  project = each.value
  role    = google_project_iam_custom_role.upwind_cloudlogs_reader_role[each.key].id
  member  = "serviceAccount:${module.iam.cloudlogs_sa_email}"
}
