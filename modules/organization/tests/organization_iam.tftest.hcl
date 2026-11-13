mock_provider "google" {}

override_data {
  target = data.google_organization.org
  values = {
    org_id = "123456789012"
  }
}

override_resource {
  target          = module.iam.google_service_account.upwind_management_sa
  override_during = plan
  values = {
    id    = "projects/upwind-orchestrator/serviceAccounts/upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    email = "upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
  }
}

override_resource {
  target          = module.iam.google_service_account.cloudscanner_sa
  override_during = plan
  values = {
    id    = "projects/upwind-orchestrator/serviceAccounts/upwind-cs@upwind-orchestrator.iam.gserviceaccount.com"
    email = "upwind-cs@upwind-orchestrator.iam.gserviceaccount.com"
  }
}

override_resource {
  target          = module.iam.google_service_account.cloudscanner_scaler_sa
  override_during = plan
  values = {
    id    = "projects/upwind-orchestrator/serviceAccounts/upwind-scaler@upwind-orchestrator.iam.gserviceaccount.com"
    email = "upwind-scaler@upwind-orchestrator.iam.gserviceaccount.com"
  }
}

variables {
  upwind_organization_id            = "org_test"
  upwind_client_id                  = "client"
  scanner_client_id                 = "scanner"
  gcp_organization_id               = "123456789012"
  upwind_orchestrator_project       = "upwind-orchestrator"
  workload_identity_trusted_account = "111111111111"
  enable_cloudscanners              = true
  enable_dspm_scanning              = true

  # Skip secret versions: Terraform 1.11's mock provider fills their write-only values at plan and fails
  create_secret_versions   = false
  upwind_client_secret_id  = "upwind-client-secret-test"
  scanner_client_secret_id = "upwind-scanner-client-secret-test"
}

run "managed_output_matches_created_resources" {
  command = plan

  assert {
    condition     = output.organization_iam_requirements.managed
    error_message = "the default should manage organization IAM"
  }
  assert {
    condition = (
      sort(google_organization_iam_custom_role.upwind_management_sa_operations_role[0].permissions) == output.organization_iam_requirements.custom_roles["UpwindOperations_test"].permissions &&
      sort(google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0].permissions) == output.organization_iam_requirements.custom_roles["CloudScannerOperationsRole_test"].permissions &&
      sort(google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0].permissions) == output.organization_iam_requirements.custom_roles["CloudScannerSnapshotDeleter_test"].permissions &&
      sort(google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role[0].permissions) == output.organization_iam_requirements.custom_roles["CloudScannerObjectReader_test"].permissions
    )
    error_message = "output custom role permissions must match the roles the module creates"
  }
  assert {
    condition = google_organization_iam_binding.upwind_cloudscanner_operations_role_binding[0].members == toset([
      for b in values(output.organization_iam_requirements.bindings) : b.member
      if b.role == output.organization_iam_requirements.custom_roles["CloudScannerOperationsRole_test"].name
    ])
    error_message = "output operations grants must match the binding the module creates"
  }
  assert {
    condition = google_organization_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding[0].members == toset([
      for b in values(output.organization_iam_requirements.bindings) : b.member
      if b.role == output.organization_iam_requirements.custom_roles["CloudScannerSnapshotDeleter_test"].name
    ])
    error_message = "output snapshot-deleter grants must match the binding the module creates"
  }
  assert {
    condition = (
      google_organization_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding[0].condition[0].expression == output.organization_iam_requirements.bindings["scaler-snapshot-deleter"].condition.expression &&
      google_organization_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding[0].condition[0].expression == output.organization_iam_requirements.bindings["cloudscanner-snapshot-deleter"].condition.expression
    )
    error_message = "output snapshot-deleter condition must match the binding the module creates"
  }
  assert {
    condition     = length(output.organization_iam_requirements.bindings) == 10
    error_message = "outpost with DSPM needs 10 organization grants"
  }
}

run "unmanaged_creates_nothing_at_organization_level" {
  command = plan

  variables {
    manage_organization_iam = false
  }

  assert {
    condition = (
      length(data.google_organization.org) == 0 &&
      length(google_organization_iam_custom_role.upwind_management_sa_operations_role) == 0 &&
      length(google_organization_iam_custom_role.upwind_cloudscanner_operations_role) == 0 &&
      length(google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role) == 0 &&
      length(google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role) == 0 &&
      length(google_organization_iam_member.upwind_management_sa_org_viewer_role_member) == 0 &&
      length(google_organization_iam_member.upwind_management_sa_folder_viewer_role_member) == 0 &&
      length(google_organization_iam_member.upwind_management_sa_operations_role_member) == 0 &&
      length(google_organization_iam_member.upwind_management_sa_asset_viewer_role_member) == 0 &&
      length(google_organization_iam_member.upwind_cloudscanner_sa_compute_viewer_role_member) == 0 &&
      length(google_organization_iam_binding.upwind_cloudscanner_operations_role_binding) == 0 &&
      length(google_organization_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding) == 0 &&
      length(google_organization_iam_binding.upwind_cloudscanner_object_reader_role_binding) == 0
    )
    error_message = "no organization-level resource or data source should be used when manage_organization_iam is false"
  }
  assert {
    condition     = module.iam.cloudscanner_scaler_sa != null && module.iam.upwind_management_sa != null
    error_message = "project-level resources should still be created"
  }
  assert {
    condition     = !output.organization_iam_requirements.managed && output.organization_iam_requirements.organization_id == "123456789012"
    error_message = "the output should use gcp_organization_id directly when unmanaged"
  }
  assert {
    condition     = output.organization_iam_requirements.custom_roles["CloudScannerOperationsRole_test"].name == "organizations/123456789012/roles/CloudScannerOperationsRole_test"
    error_message = "custom role names should be full resource names"
  }
  assert {
    condition = output.organization_iam_requirements.bindings["scaler-operations"] == {
      role      = "organizations/123456789012/roles/CloudScannerOperationsRole_test"
      member    = "serviceAccount:upwind-scaler@upwind-orchestrator.iam.gserviceaccount.com"
      condition = null
    }
    error_message = "the scaler must be granted the operations role"
  }
  assert {
    condition     = output.organization_iam_requirements.bindings["cloudscanner-object-reader"].member == "serviceAccount:upwind-cs@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "the object reader grant must be listed when DSPM is enabled"
  }
  assert {
    condition = output.organization_iam_requirements.by_service_account["serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"] == sort([
      "organizations/123456789012/roles/UpwindOperations_test",
      "roles/cloudasset.viewer",
      "roles/resourcemanager.folderViewer",
      "roles/viewer",
    ])
    error_message = "by_service_account should summarise the management SA's roles"
  }
}

run "unmanaged_saas_lists_no_scaler_grants" {
  command = plan

  variables {
    manage_organization_iam        = false
    enable_dspm_scanning           = false
    is_saas                        = true
    workload_identity_saas_subject = "123456789012345678901"
    upwind_client_id               = ""
    upwind_client_secret_id        = ""
    scanner_client_id              = ""
    scanner_client_secret_id       = ""
  }

  assert {
    condition     = sort(keys(output.organization_iam_requirements.bindings)) == sort(["management-viewer", "management-folder-viewer", "management-asset-viewer", "management-operations", "cloudscanner-operations", "cloudscanner-snapshot-deleter"])
    error_message = "SaaS needs no scaler, compute.viewer or object reader grants"
  }
  assert {
    condition     = output.organization_iam_requirements.bindings["cloudscanner-operations"].member == "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "in SaaS mode the management SA is the scanner identity"
  }
}

run "unmanaged_without_scanners_lists_management_only" {
  command = plan

  variables {
    manage_organization_iam = false
    enable_cloudscanners    = false
    enable_dspm_scanning    = false
  }

  assert {
    condition     = keys(output.organization_iam_requirements.custom_roles) == ["UpwindOperations_test"]
    error_message = "only the management operations role is needed without scanners"
  }
  assert {
    condition     = length(output.organization_iam_requirements.bindings) == 4
    error_message = "only the 4 management grants are needed without scanners"
  }
}
