### State migration for IAM binding to IAM member conversion
# These moved blocks ensure existing deployments migrate smoothly without
# destroying and recreating IAM bindings (which would cause service disruption)

# Migration for cloudscanner operations role binding -> member resources
# Note: google_project_iam_binding manages all members for a role, while
# google_project_iam_member manages a single member. The binding resource
# will be removed from state and replaced with individual member resources.

moved {
  from = google_project_iam_binding.upwind_cloudscanner_operations_role_binding
  to   = google_project_iam_member.upwind_cloudscanner_sa_operations_role_member
}

moved {
  from = google_project_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding
  to   = google_project_iam_member.upwind_cloudscanner_sa_snapshot_deleter_role_member
}
