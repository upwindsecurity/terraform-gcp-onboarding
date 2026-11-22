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

override_resource {
  target          = module.iam.google_service_account.cloudlogs_sa
  override_during = plan
  values = {
    id    = "projects/upwind-orchestrator/serviceAccounts/upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"
    email = "upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"
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
    condition     = length(output.organization_iam_requirements.bindings) == 11
    error_message = "outpost with DSPM needs 11 organization grants"
  }
  assert {
    condition = (
      google_organization_iam_member.upwind_management_sa_container_viewer_role_member[0].role == output.organization_iam_requirements.bindings["management-container-viewer"].role &&
      google_organization_iam_member.upwind_management_sa_container_viewer_role_member[0].member == output.organization_iam_requirements.bindings["management-container-viewer"].member
    )
    error_message = "output container.viewer grant must match the member the module creates"
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
      length(google_organization_iam_member.upwind_management_sa_container_viewer_role_member) == 0 &&
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
      "roles/container.viewer",
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
    condition     = sort(keys(output.organization_iam_requirements.bindings)) == sort(["management-viewer", "management-folder-viewer", "management-asset-viewer", "management-container-viewer", "management-operations", "cloudscanner-operations", "cloudscanner-snapshot-deleter"])
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
    condition     = length(output.organization_iam_requirements.bindings) == 5
    error_message = "only the 5 management grants are needed without scanners"
  }
}

run "management_sa_gets_explicit_container_viewer" {
  command = plan

  assert {
    condition     = google_organization_iam_member.upwind_management_sa_container_viewer_role_member[0].role == "roles/container.viewer"
    error_message = "the management SA needs an explicit roles/container.viewer grant so GKE access survives replacing roles/viewer"
  }
  assert {
    condition     = google_organization_iam_member.upwind_management_sa_container_viewer_role_member[0].member == "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "the container.viewer grant must go to the management SA"
  }
}

run "rejects_non_numeric_organization_id" {
  command = plan

  variables {
    manage_organization_iam = false
    gcp_organization_id     = "123456789012 "
  }

  expect_failures = [var.gcp_organization_id]
}

run "cloudlogs_disabled_creates_nothing" {
  command = plan

  assert {
    condition = (
      length(google_organization_iam_custom_role.upwind_cloudlogs_reader_role) == 0 &&
      length(google_organization_iam_member.upwind_cloudlogs_sa_reader_role_member) == 0 &&
      output.upwind_cloudlogs_service_account_email == null &&
      !contains(keys(output.organization_iam_requirements.bindings), "cloudlogs-reader") &&
      !contains(keys(output.organization_iam_requirements.custom_roles), "UpwindCloudLogsReader_test")
    )
    error_message = "nothing for cloud logs should be created or listed unless enable_cloudlogs is true"
  }
}

run "cloudlogs_grants_reader_role_at_organization" {
  command = plan

  variables {
    enable_cloudlogs = true
  }

  assert {
    condition = (
      google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].org_id == "123456789012" &&
      google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].role_id == "UpwindCloudLogsReader_test" &&
      google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].title == "upwind-role-test-cloudlogs-reader" &&
      sort(google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].permissions) == tolist(["logging.sinks.get", "monitoring.timeSeries.list"])
    )
    error_message = "the cloud logs reader role must hold exactly logging.sinks.get and monitoring.timeSeries.list"
  }
  assert {
    condition = (
      google_organization_iam_member.upwind_cloudlogs_sa_reader_role_member[0].org_id == "123456789012" &&
      google_organization_iam_member.upwind_cloudlogs_sa_reader_role_member[0].member == "serviceAccount:upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"
    )
    error_message = "the cloud logs reader role must be granted to the cloud logs SA at the organization"
  }
  assert {
    condition     = output.upwind_cloudlogs_service_account_email == "upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "the module must output the cloud logs SA email"
  }
  assert {
    condition = (
      sort(google_organization_iam_custom_role.upwind_cloudlogs_reader_role[0].permissions) == output.organization_iam_requirements.custom_roles["UpwindCloudLogsReader_test"].permissions &&
      google_organization_iam_member.upwind_cloudlogs_sa_reader_role_member[0].member == output.organization_iam_requirements.bindings["cloudlogs-reader"].member
    )
    error_message = "output cloud logs role and grant must match the resources the module creates"
  }
}

run "unmanaged_cloudlogs_lists_reader_grant" {
  command = plan

  variables {
    manage_organization_iam = false
    enable_cloudlogs        = true
  }

  assert {
    condition = (
      length(google_organization_iam_custom_role.upwind_cloudlogs_reader_role) == 0 &&
      length(google_organization_iam_member.upwind_cloudlogs_sa_reader_role_member) == 0
    )
    error_message = "no organization-level cloud logs resource should be created when manage_organization_iam is false"
  }
  assert {
    condition = output.organization_iam_requirements.bindings["cloudlogs-reader"] == {
      role      = "organizations/123456789012/roles/UpwindCloudLogsReader_test"
      member    = "serviceAccount:upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"
      condition = null
    }
    error_message = "the cloud logs reader grant must be listed for customers who manage organization IAM"
  }
  assert {
    condition = (
      output.organization_iam_requirements.custom_roles["UpwindCloudLogsReader_test"].name == "organizations/123456789012/roles/UpwindCloudLogsReader_test" &&
      output.organization_iam_requirements.custom_roles["UpwindCloudLogsReader_test"].title == "upwind-role-test-cloudlogs-reader" &&
      output.organization_iam_requirements.custom_roles["UpwindCloudLogsReader_test"].permissions == tolist(["logging.sinks.get", "monitoring.timeSeries.list"])
    )
    error_message = "the cloud logs reader role must be listed for customers who manage organization IAM"
  }
  assert {
    condition = output.organization_iam_requirements.by_service_account["serviceAccount:upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"] == tolist([
      "organizations/123456789012/roles/UpwindCloudLogsReader_test",
    ])
    error_message = "by_service_account should list the cloud logs SA's role"
  }
}
