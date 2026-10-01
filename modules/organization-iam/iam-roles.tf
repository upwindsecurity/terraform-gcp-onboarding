# Organization IAM for the management service account.
# Same role id, title, and permissions as modules/organization/iam-roles.tf.
# Permission lists come from modules/_shared/permissions.

resource "google_organization_iam_custom_role" "upwind_management_sa_operations_role" {
  org_id      = data.google_organization.org.org_id
  role_id     = local.operations_role_id
  title       = "upwind-role-${local.resource_suffix_hyphen}-operations"
  description = "Generic operations role for Upwind"
  permissions = concat(
    module.permissions.storage_read_permissions,
    module.permissions.organization_iam_read_permissions,
    var.enable_cloudscanners ? module.permissions.iam_read_role_permissions : [],
  )
}

resource "google_organization_iam_member" "upwind_management_sa_org_viewer_role_member" {
  org_id = data.google_organization.org.org_id
  role   = "roles/viewer"
  member = "serviceAccount:${var.upwind_management_sa_email}"
}

resource "google_organization_iam_member" "upwind_management_sa_folder_viewer_role_member" {
  org_id = data.google_organization.org.org_id
  role   = "roles/resourcemanager.folderViewer"
  member = "serviceAccount:${var.upwind_management_sa_email}"
}

resource "google_organization_iam_member" "upwind_management_sa_operations_role_member" {
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_management_sa_operations_role.id
  member = "serviceAccount:${var.upwind_management_sa_email}"
}

resource "google_organization_iam_member" "upwind_management_sa_asset_viewer_role_member" {
  org_id = data.google_organization.org.org_id
  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${var.upwind_management_sa_email}"
}
