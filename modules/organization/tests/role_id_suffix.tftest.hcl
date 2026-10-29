mock_provider "google" {}

variables {
  upwind_organization_id            = "org_knNDkklPjw0zavca"
  upwind_client_id                  = "client"
  upwind_client_secret              = "secret"
  scanner_client_id                 = "scanner-client"
  scanner_client_secret             = "scanner-secret"
  gcp_organization_id               = "123456789012"
  upwind_orchestrator_project       = "orchestrator"
  workload_identity_trusted_account = "123456789012"
  enable_cloudscanners              = true
  enable_dspm_scanning              = true
  resource_suffix                   = "r9i04vnj"
}

run "prod_role_ids_include_resource_suffix" {
  command = plan

  assert {
    condition     = google_organization_iam_custom_role.upwind_management_sa_operations_role.role_id == "UpwindOperations_zavca_r9i04vnj"
    error_message = "prod org role ID must keep the resource suffix"
  }
  assert {
    condition     = google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role[0].role_id == "CloudScannerObjectReader_zavca_r9i04vnj"
    error_message = "prod org role ID must keep the resource suffix"
  }
}

run "dev_role_ids_drop_resource_suffix" {
  command = plan
  variables { is_dev = true }

  assert {
    condition     = google_organization_iam_custom_role.upwind_management_sa_operations_role.role_id == "UpwindOperations_zavca"
    error_message = "dev org role ID must be keyed on the Upwind org only"
  }
  assert {
    condition     = google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0].role_id == "CloudScannerSnapshotDeleter_zavca"
    error_message = "dev org role ID must be keyed on the Upwind org only"
  }
}

run "dev_role_id_suffix_moves_to_fresh_role_ids" {
  command = plan
  variables {
    is_dev         = true
    role_id_suffix = "b2"
  }

  assert {
    condition     = google_organization_iam_custom_role.upwind_management_sa_operations_role.role_id == "UpwindOperations_zavca_b2"
    error_message = "dev role_id_suffix must be appended to the Upwind org"
  }
}
