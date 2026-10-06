output "operations_role_id" {
  description = "ID of the Upwind management operations custom role."
  value       = google_organization_iam_custom_role.upwind_management_sa_operations_role.role_id
}

output "operations_role_name" {
  description = "Full resource name of the Upwind management operations custom role."
  value       = google_organization_iam_custom_role.upwind_management_sa_operations_role.name
}

output "cloudscanner_operations_role_id" {
  description = "ID of the CloudScanner operations custom role. Null when cloud scanners are disabled."
  value       = try(google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0].role_id, null)
}

output "cloudscanner_snapshot_deleter_role_id" {
  description = "ID of the CloudScanner snapshot deleter custom role. Null when cloud scanners are disabled."
  value       = try(google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0].role_id, null)
}

output "cloudscanner_object_reader_role_id" {
  description = "ID of the CloudScanner object reader custom role. Null unless cloud scanners and DSPM scanning are enabled."
  value       = try(google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role[0].role_id, null)
}
