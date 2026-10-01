output "storage_read_permissions" {
  description = "IAM permissions for storage read access."
  value       = local.storage_read_permissions
}

output "iam_read_role_permissions" {
  description = "IAM permissions for read-only access across GCP services."
  value       = local.iam_read_role_permissions
}

output "organization_iam_read_permissions" {
  description = "IAM permissions for reading the organization IAM policy."
  value       = local.organization_iam_read_permissions
}

output "snapshot_reader_permissions" {
  description = "IAM permissions for reading snapshots."
  value       = local.snapshot_reader_permissions
}

output "snapshot_creator_permissions" {
  description = "IAM permissions for creating snapshots and scan resources in target projects. Does not include iam.serviceAccounts.actAs; callers append that when enable_snapshot_act_as is true."
  value       = local.snapshot_creator_permissions
}

output "snapshot_deleter_permissions" {
  description = "IAM permissions for deleting snapshots."
  value       = local.snapshot_deleter_permissions
}

output "storage_object_reader_permissions" {
  description = "IAM permissions for storage object read access."
  value       = local.storage_object_reader_permissions
}

output "cloud_run_permissions" {
  description = "IAM permissions for Cloud Run artifact access."
  value       = local.cloud_run_permissions
}
