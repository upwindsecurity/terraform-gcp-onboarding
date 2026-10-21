# CloudScanner organization IAM.
# Same role ids, titles, and permissions as modules/organization/iam-roles-cloudscanner.tf.
# Bindings are additive google_organization_iam_member resources so a central IAM
# pipeline does not replace the full member list for these roles.

resource "google_organization_iam_custom_role" "upwind_cloudscanner_operations_role" {
  count       = var.enable_cloudscanners ? 1 : 0
  org_id      = data.google_organization.org.org_id
  role_id     = local.cloudscanner_operations_role_id
  title       = "upwind-role-${local.resource_suffix_hyphen}-cloudscanner-operations"
  description = "Generic Operations role for CloudScanner"
  permissions = local.cloudscanner_operations_permissions
}

resource "google_organization_iam_custom_role" "upwind_cloudscanner_snapshot_deleter_role" {
  count       = var.enable_cloudscanners ? 1 : 0
  org_id      = data.google_organization.org.org_id
  role_id     = local.cloudscanner_snapshot_deleter_role_id
  title       = "upwind-role-${local.resource_suffix_hyphen}-snapshot-deleter"
  description = "Delete operations restricted to Upwind-managed resources"
  permissions = module.permissions.snapshot_deleter_permissions
}

resource "google_organization_iam_custom_role" "upwind_cloudscanner_object_reader_role" {
  count       = var.enable_cloudscanners && var.enable_dspm_scanning ? 1 : 0
  org_id      = data.google_organization.org.org_id
  role_id     = local.cloudscanner_object_reader_role_id
  title       = "upwind-role-${local.resource_suffix_hyphen}-cloudscanner-object-reader"
  description = "Object read access for DSPM scanning"
  permissions = module.permissions.storage_object_reader_permissions
}

resource "google_organization_iam_member" "upwind_cloudscanner_sa_object_reader_role_member" {
  count  = var.enable_cloudscanners && var.enable_dspm_scanning ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role[0].id
  member = "serviceAccount:${var.cloudscanner_sa_email}"
}

resource "google_organization_iam_member" "upwind_cloudscanner_sa_compute_viewer_role_member" {
  count  = var.enable_cloudscanners ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = "roles/compute.viewer"
  member = "serviceAccount:${var.cloudscanner_sa_email}"
}

resource "google_organization_iam_member" "upwind_cloudscanner_sa_operations_role_member" {
  count  = var.enable_cloudscanners ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0].id
  member = "serviceAccount:${var.cloudscanner_sa_email}"
}

resource "google_organization_iam_member" "upwind_cloudscanner_scaler_sa_operations_role_member" {
  count  = var.enable_cloudscanners ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0].id
  member = "serviceAccount:${var.cloudscanner_scaler_sa_email}"
}

resource "google_organization_iam_member" "upwind_cloudscanner_sa_snapshot_deleter_role_member" {
  count  = var.enable_cloudscanners ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0].id
  member = "serviceAccount:${var.cloudscanner_sa_email}"

  condition {
    title      = "Upwind Cloud Scanner Snapshot Deleter"
    expression = "resource.name.extract('snapshots/{snapshot}').startsWith('snap-')"
  }
}

resource "google_organization_iam_member" "upwind_cloudscanner_scaler_sa_snapshot_deleter_role_member" {
  count  = var.enable_cloudscanners ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0].id
  member = "serviceAccount:${var.cloudscanner_scaler_sa_email}"

  condition {
    title      = "Upwind Cloud Scanner Snapshot Deleter"
    expression = "resource.name.extract('snapshots/{snapshot}').startsWith('snap-')"
  }
}
