module "permissions" {
  source = "../permissions"
}

locals {
  storage_read_permissions          = var.storage_read_permissions != null ? var.storage_read_permissions : module.permissions.storage_read_permissions
  iam_read_role_permissions         = var.iam_read_role_permissions != null ? var.iam_read_role_permissions : module.permissions.iam_read_role_permissions
  organization_iam_read_permissions = var.organization_iam_read_permissions != null ? var.organization_iam_read_permissions : module.permissions.organization_iam_read_permissions
  snapshot_reader_permissions       = var.snapshot_reader_permissions != null ? var.snapshot_reader_permissions : module.permissions.snapshot_reader_permissions
  snapshot_creator_permissions      = var.snapshot_creator_permissions != null ? var.snapshot_creator_permissions : module.permissions.snapshot_creator_permissions
  snapshot_deleter_permissions      = var.snapshot_deleter_permissions != null ? var.snapshot_deleter_permissions : module.permissions.snapshot_deleter_permissions
  storage_object_reader_permissions = var.storage_object_reader_permissions != null ? var.storage_object_reader_permissions : module.permissions.storage_object_reader_permissions
  cloud_run_permissions             = var.cloud_run_permissions != null ? var.cloud_run_permissions : module.permissions.cloud_run_permissions
}
