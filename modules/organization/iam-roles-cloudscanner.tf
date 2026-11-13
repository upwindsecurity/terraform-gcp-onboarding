# Definitions live in organization-iam.tf. Nothing here is created when manage_organization_iam is false.

locals {
  manage_cloudscanner_org_iam  = var.manage_organization_iam && var.enable_cloudscanners
  manage_object_reader_org_iam = local.manage_cloudscanner_org_iam && var.enable_dspm_scanning

  # Members of the operations and snapshot-deleter roles: the scanner identity plus, outside SaaS, the scaler
  cloudscanner_operations_members = compact([local.cloudscanner_member, local.scaler_member])
}

# Generic operations role for CloudScanner
resource "google_organization_iam_custom_role" "upwind_cloudscanner_operations_role" {
  count       = local.manage_cloudscanner_org_iam ? 1 : 0
  org_id      = local.organization_id
  role_id     = local.organization_custom_roles.cloudscanner_operations.role_id
  title       = local.organization_custom_roles.cloudscanner_operations.title
  description = local.organization_custom_roles.cloudscanner_operations.description
  permissions = local.organization_custom_roles.cloudscanner_operations.permissions
}

# Snapshot deleter role separate to limit delete permissions to named resources
resource "google_organization_iam_custom_role" "upwind_cloudscanner_snapshot_deleter_role" {
  count       = local.manage_cloudscanner_org_iam ? 1 : 0
  org_id      = local.organization_id
  role_id     = local.organization_custom_roles.cloudscanner_snapshot_deleter.role_id
  title       = local.organization_custom_roles.cloudscanner_snapshot_deleter.title
  description = local.organization_custom_roles.cloudscanner_snapshot_deleter.description
  permissions = local.organization_custom_roles.cloudscanner_snapshot_deleter.permissions
}

# Object read role for DSPM scanning
resource "google_organization_iam_custom_role" "upwind_cloudscanner_object_reader_role" {
  count       = local.manage_object_reader_org_iam ? 1 : 0
  org_id      = local.organization_id
  role_id     = local.organization_custom_roles.cloudscanner_object_reader.role_id
  title       = local.organization_custom_roles.cloudscanner_object_reader.title
  description = local.organization_custom_roles.cloudscanner_object_reader.description
  permissions = local.organization_custom_roles.cloudscanner_object_reader.permissions
}

# Required to get instances across projects. In SaaS mode the management SA already holds roles/viewer
resource "google_organization_iam_member" "upwind_cloudscanner_sa_compute_viewer_role_member" {
  count  = local.manage_cloudscanner_org_iam && !var.is_saas ? 1 : 0
  org_id = local.organization_id
  role   = local.organization_iam_bindings["cloudscanner-compute-viewer"].role
  member = local.organization_iam_bindings["cloudscanner-compute-viewer"].member

  depends_on = [
    module.iam.cloudscanner_sa
  ]
}

# Required to get disks and snapshots of target instances across projects
resource "google_organization_iam_binding" "upwind_cloudscanner_operations_role_binding" {
  count   = local.manage_cloudscanner_org_iam ? 1 : 0
  org_id  = local.organization_id
  role    = google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0].name
  members = local.cloudscanner_operations_members

  depends_on = [
    module.iam.cloudscanner_sa,
    module.iam.cloudscanner_scaler_sa,
  ]
}

# Limit snapshot deletion permissions to Upwind-generated snapshots only
resource "google_organization_iam_binding" "upwind_cloudscanner_snapshot_deleter_role_binding" {
  count   = local.manage_cloudscanner_org_iam ? 1 : 0
  org_id  = local.organization_id
  role    = google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0].name
  members = local.cloudscanner_operations_members
  condition {
    # Limit storage deletion permissions to snapshots we generate only
    title      = local.snapshot_deleter_condition.title
    expression = local.snapshot_deleter_condition.expression
  }

  depends_on = [
    module.iam.cloudscanner_sa,
    module.iam.cloudscanner_scaler_sa,
  ]
}

# Grant the object read role to the CloudScanner SA across the organization
resource "google_organization_iam_binding" "upwind_cloudscanner_object_reader_role_binding" {
  count   = local.manage_object_reader_org_iam ? 1 : 0
  org_id  = local.organization_id
  role    = google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role[0].name
  members = [local.organization_iam_bindings["cloudscanner-object-reader"].member]

  depends_on = [
    module.iam.cloudscanner_sa,
  ]
}
