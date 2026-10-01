# Organization IAM for the management service account.
# Skipped when manage_organization_iam is false; modules/organization-iam applies the same grants.
# Keep role ids, titles, and permission lists aligned with that module.

### Custom Roles

# Custom role for Storage reader and IAM management with minimal required permissions
resource "google_organization_iam_custom_role" "upwind_management_sa_operations_role" {
  count       = var.manage_organization_iam ? 1 : 0
  org_id      = data.google_organization.org.org_id
  role_id     = "UpwindOperations_${local.resource_suffix_underscore}"
  title       = "upwind-role-${local.resource_suffix_hyphen}-operations"
  description = "Generic operations role for Upwind"
  permissions = concat(
    module.iam.storage_read_permissions,
    module.iam.organization_iam_read_permissions,
    var.enable_cloudscanners ? module.iam.iam_read_role_permissions : [],
  )
}

### IAM Members

# Give the management service account the basic viewer role
# We will grant more permissions if Cloud Scanners are enabled
resource "google_organization_iam_member" "upwind_management_sa_org_viewer_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = "roles/viewer"
  member = "serviceAccount:${module.iam.upwind_management_sa.email}"

  depends_on = [
    module.iam.upwind_management_sa
  ]
}

resource "google_organization_iam_member" "upwind_management_sa_folder_viewer_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = "roles/resourcemanager.folderViewer"
  member = "serviceAccount:${module.iam.upwind_management_sa.email}"

  depends_on = [
    module.iam.upwind_management_sa
  ]
}

# Assign the operations role to the management service account (unconditional)
resource "google_organization_iam_member" "upwind_management_sa_operations_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = google_organization_iam_custom_role.upwind_management_sa_operations_role[0].id
  member = "serviceAccount:${module.iam.upwind_management_sa.email}"

  depends_on = [
    module.iam.upwind_management_sa
  ]
}

# Grant Cloud Asset Inventory permissions for customer-asset-collector across all projects
resource "google_organization_iam_member" "upwind_management_sa_asset_viewer_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = data.google_organization.org.org_id
  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${module.iam.upwind_management_sa.email}"

  depends_on = [
    module.iam.upwind_management_sa
  ]
}
