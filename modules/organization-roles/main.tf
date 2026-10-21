locals {
  # Same suffix rules as modules/organization and modules/_shared/iam.
  # SA names can't have underscores and have a small limit on length.
  org_id_sanitized           = replace(lower(var.upwind_organization_id), "org_", "")
  org_id_truncated           = substr(local.org_id_sanitized, max(0, length(local.org_id_sanitized) - 5), 5)
  resource_suffix_hyphen     = format("%s%s", local.org_id_truncated, var.resource_suffix == "" ? "" : "-${var.resource_suffix}")
  resource_suffix_underscore = format("%s%s", local.org_id_truncated, var.resource_suffix == "" ? "" : "_${var.resource_suffix}")

  operations_role_id                    = "UpwindOperations_${local.resource_suffix_underscore}"
  cloudscanner_operations_role_id       = "CloudScannerOperationsRole_${local.resource_suffix_underscore}"
  cloudscanner_snapshot_deleter_role_id = "CloudScannerSnapshotDeleter_${local.resource_suffix_underscore}"
  cloudscanner_object_reader_role_id    = "CloudScannerObjectReader_${local.resource_suffix_underscore}"

  # actAs sits on the end of the snapshot-creator segment, matching module.iam.snapshot_creator_permissions.
  # DSPM object read is a separate role, matching modules/organization/iam-roles-cloudscanner.tf.
  cloudscanner_operations_permissions = concat(
    module.permissions.iam_read_role_permissions,
    module.permissions.snapshot_reader_permissions,
    module.permissions.snapshot_creator_permissions,
    var.enable_snapshot_act_as ? ["iam.serviceAccounts.actAs"] : [],
    module.permissions.cloud_run_permissions,
    module.permissions.storage_read_permissions,
  )
}

data "google_organization" "org" {
  organization = var.gcp_organization_id
}

module "permissions" {
  source = "../_shared/permissions"
}
