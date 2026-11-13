# Organization-level IAM requirements.
#
# Single source of truth for the org custom roles and grants. The resources in iam-roles.tf and
# iam-roles-cloudscanner.tf are built from these locals, and the organization_iam_requirements
# output publishes them, so customers who manage org IAM themselves (manage_organization_iam = false)
# get exactly what the module would otherwise create.

locals {
  organization_id = var.manage_organization_iam ? data.google_organization.org[0].org_id : var.gcp_organization_id

  management_sa_member = "serviceAccount:${module.iam.upwind_management_sa.email}"
  cloudscanner_member  = var.enable_cloudscanners ? "serviceAccount:${module.iam.cloudscanner_identity_email}" : null
  # The scaler SA only exists when scanners are deployed in the customer's project
  scaler_member = var.enable_cloudscanners && !var.is_saas ? "serviceAccount:${module.iam.cloudscanner_scaler_sa.email}" : null

  snapshot_deleter_condition = {
    title      = "Upwind Cloud Scanner Snapshot Deleter"
    expression = "resource.name.extract('snapshots/{snapshot}').startsWith('snap-') && resource.name.extract('snapshots/snap-{rest}-ucsc-') != ''"
  }

  # Custom roles keyed by their logical name in this module
  organization_custom_roles = merge(
    {
      management_operations = {
        role_id     = "UpwindOperations_${local.resource_suffix_underscore}"
        title       = "upwind-role-${local.resource_suffix_hyphen}-operations"
        description = "Generic operations role for Upwind"
        permissions = concat(
          module.iam.storage_read_permissions,
          module.iam.organization_iam_read_permissions,
          var.enable_cloudscanners ? module.iam.iam_read_role_permissions : [],
        )
      }
    },
    var.enable_cloudscanners ? {
      cloudscanner_operations = {
        role_id     = "CloudScannerOperationsRole_${local.resource_suffix_underscore}"
        title       = "upwind-role-${local.resource_suffix_hyphen}-cloudscanner-operations"
        description = "Generic Operations role for CloudScanner"
        permissions = concat(
          module.iam.iam_read_role_permissions,
          module.iam.snapshot_reader_permissions,
          module.iam.snapshot_creator_permissions,
          module.iam.cloud_run_permissions,
          module.iam.storage_read_permissions,
        )
      }
      cloudscanner_snapshot_deleter = {
        role_id     = "CloudScannerSnapshotDeleter_${local.resource_suffix_underscore}"
        title       = "upwind-role-${local.resource_suffix_hyphen}-snapshot-deleter"
        description = "Delete operations restricted to Upwind-managed resources"
        permissions = module.iam.snapshot_deleter_permissions
      }
    } : {},
    var.enable_cloudscanners && var.enable_dspm_scanning ? {
      cloudscanner_object_reader = {
        role_id     = "CloudScannerObjectReader_${local.resource_suffix_underscore}"
        title       = "upwind-role-${local.resource_suffix_hyphen}-cloudscanner-object-reader"
        description = "Object read access for DSPM scanning"
        permissions = module.iam.storage_object_reader_permissions
      }
    } : {},
  )

  organization_custom_role_names = {
    for k, r in local.organization_custom_roles : k => "organizations/${local.organization_id}/roles/${r.role_id}"
  }

  # Every grant the module can make, one per (role, member), with when it applies
  organization_iam_binding_candidates = {
    management-viewer = {
      enabled   = true
      role      = "roles/viewer"
      member    = local.management_sa_member
      condition = null
    }
    management-folder-viewer = {
      enabled   = true
      role      = "roles/resourcemanager.folderViewer"
      member    = local.management_sa_member
      condition = null
    }
    management-asset-viewer = {
      enabled   = true
      role      = "roles/cloudasset.viewer"
      member    = local.management_sa_member
      condition = null
    }
    management-operations = {
      enabled   = true
      role      = local.organization_custom_role_names.management_operations
      member    = local.management_sa_member
      condition = null
    }
    # In SaaS mode the management SA already holds roles/viewer
    cloudscanner-compute-viewer = {
      enabled   = var.enable_cloudscanners && !var.is_saas
      role      = "roles/compute.viewer"
      member    = local.cloudscanner_member
      condition = null
    }
    cloudscanner-operations = {
      enabled   = var.enable_cloudscanners
      role      = try(local.organization_custom_role_names.cloudscanner_operations, null)
      member    = local.cloudscanner_member
      condition = null
    }
    cloudscanner-snapshot-deleter = {
      enabled   = var.enable_cloudscanners
      role      = try(local.organization_custom_role_names.cloudscanner_snapshot_deleter, null)
      member    = local.cloudscanner_member
      condition = local.snapshot_deleter_condition
    }
    cloudscanner-object-reader = {
      enabled   = var.enable_cloudscanners && var.enable_dspm_scanning
      role      = try(local.organization_custom_role_names.cloudscanner_object_reader, null)
      member    = local.cloudscanner_member
      condition = null
    }
    scaler-operations = {
      enabled   = local.scaler_member != null
      role      = try(local.organization_custom_role_names.cloudscanner_operations, null)
      member    = local.scaler_member
      condition = null
    }
    scaler-snapshot-deleter = {
      enabled   = local.scaler_member != null
      role      = try(local.organization_custom_role_names.cloudscanner_snapshot_deleter, null)
      member    = local.scaler_member
      condition = local.snapshot_deleter_condition
    }
  }

  organization_iam_bindings = {
    for k, b in local.organization_iam_binding_candidates : k => {
      role      = b.role
      member    = b.member
      condition = b.condition
    } if b.enabled
  }

  organization_iam_requirements = {
    schema_version  = 1
    managed         = var.manage_organization_iam
    organization_id = local.organization_id
    custom_roles = {
      for k, r in local.organization_custom_roles : r.role_id => {
        name        = local.organization_custom_role_names[k]
        title       = r.title
        description = r.description
        permissions = sort(distinct(r.permissions))
      }
    }
    bindings = local.organization_iam_bindings
    by_service_account = {
      for member, roles in { for b in values(local.organization_iam_bindings) : b.member => b.role... } :
      member => sort(distinct(roles))
    }
  }
}
