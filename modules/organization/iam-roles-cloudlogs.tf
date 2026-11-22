# Definitions live in organization-iam.tf. Nothing here is created when manage_organization_iam is false.

locals {
  manage_cloudlogs_org_iam = var.manage_organization_iam && var.enable_cloudlogs
}

# Read access to log sinks and monitoring time series for audit logs integrations
resource "google_organization_iam_custom_role" "upwind_cloudlogs_reader_role" {
  count       = local.manage_cloudlogs_org_iam ? 1 : 0
  org_id      = local.organization_id
  role_id     = local.organization_custom_roles.cloudlogs_reader.role_id
  title       = local.organization_custom_roles.cloudlogs_reader.title
  description = local.organization_custom_roles.cloudlogs_reader.description
  permissions = local.organization_custom_roles.cloudlogs_reader.permissions
}

resource "google_organization_iam_member" "upwind_cloudlogs_sa_reader_role_member" {
  count  = local.manage_cloudlogs_org_iam ? 1 : 0
  org_id = local.organization_id
  role   = google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].name
  member = local.organization_iam_bindings["cloudlogs-reader"].member
}
