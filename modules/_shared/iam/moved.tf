### State migration for IAM binding to IAM member conversion
# These moved blocks ensure existing deployments migrate smoothly without
# destroying and recreating IAM bindings (which would cause service disruption)

# Migration for disk writer role binding -> member resources
# Note: google_project_iam_binding manages all members for a role, while
# google_project_iam_member manages a single member. The binding resource
# will be removed from state and replaced with individual member resources.
# Only the first member (cloudscanner_sa) is migrated; the second member
# (cloudscanner_scaler_sa) will be created as a new resource.

moved {
  from = google_project_iam_binding.cloudscanner_disk_writer_role_binding
  to   = google_project_iam_member.cloudscanner_sa_disk_writer_role_member
}
