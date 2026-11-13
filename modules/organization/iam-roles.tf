### Custom Roles
# Definitions live in organization-iam.tf. Nothing here is created when manage_organization_iam is false.

# Custom role for Storage reader and IAM management with minimal required permissions
resource "google_organization_iam_custom_role" "upwind_management_sa_operations_role" {
  count       = var.manage_organization_iam ? 1 : 0
  org_id      = local.organization_id
  role_id     = local.organization_custom_roles.management_operations.role_id
  title       = local.organization_custom_roles.management_operations.title
  description = local.organization_custom_roles.management_operations.description
  permissions = local.organization_custom_roles.management_operations.permissions
}

### IAM Members

# Give the management service account the basic viewer role
# We will grant more permissions if Cloud Scanners are enabled
resource "google_organization_iam_member" "upwind_management_sa_org_viewer_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = local.organization_id
  role   = local.organization_iam_bindings["management-viewer"].role
  member = local.organization_iam_bindings["management-viewer"].member

  depends_on = [
    module.iam.upwind_management_sa
  ]
}

resource "google_organization_iam_member" "upwind_management_sa_folder_viewer_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = local.organization_id
  role   = local.organization_iam_bindings["management-folder-viewer"].role
  member = local.organization_iam_bindings["management-folder-viewer"].member

  depends_on = [
    module.iam.upwind_management_sa
  ]
}

# Assign the operations role to the management service account (unconditional)
resource "google_organization_iam_member" "upwind_management_sa_operations_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = local.organization_id
  role   = google_organization_iam_custom_role.upwind_management_sa_operations_role[0].id
  member = local.organization_iam_bindings["management-operations"].member

  depends_on = [
    module.iam.upwind_management_sa
  ]
}

# Grant Cloud Asset Inventory permissions for customer-asset-collector across all projects
resource "google_organization_iam_member" "upwind_management_sa_asset_viewer_role_member" {
  count  = var.manage_organization_iam ? 1 : 0
  org_id = local.organization_id
  role   = local.organization_iam_bindings["management-asset-viewer"].role
  member = local.organization_iam_bindings["management-asset-viewer"].member

  depends_on = [
    module.iam.upwind_management_sa
  ]
}
