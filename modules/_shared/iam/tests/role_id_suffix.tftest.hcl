mock_provider "google" {}

variables {
  upwind_organization_id              = "org_knNDkklPjw0zavca"
  upwind_client_id                    = "client"
  upwind_client_secret                = "secret"
  scanner_client_id                   = "scanner-client"
  scanner_client_secret               = "scanner-secret"
  upwind_orchestrator_project         = "orchestrator"
  workload_identity_trusted_account   = "123456789012"
  google_service_account_display_name = "Upwind"
  enable_cloudscanners                = true
  resource_suffix                     = "r9i04vnj"
}

run "prod_role_ids_include_resource_suffix" {
  command = plan

  assert {
    condition     = google_project_iam_custom_role.upwind_management_sa_cloudscanner_deployment_role[0].role_id == "CloudScannerDeploymentRole_zavca_r9i04vnj"
    error_message = "prod project role ID must keep the resource suffix"
  }
  assert {
    condition     = google_service_account.cloudscanner_sa[0].account_id == "upwind-cs-zavca-r9i04vnj"
    error_message = "service account naming must be unaffected"
  }
}

run "dev_role_ids_drop_resource_suffix" {
  command = plan
  variables { is_dev = true }

  assert {
    condition     = google_project_iam_custom_role.upwind_management_sa_cloudscanner_deployment_role[0].role_id == "CloudScannerDeploymentRole_zavca"
    error_message = "dev project role ID must be keyed on the Upwind org only"
  }
  assert {
    condition     = google_project_iam_custom_role.compute_service_agent_minimal[0].role_id == "ComputeServiceAgentMinimal_zavca"
    error_message = "dev project role ID must be keyed on the Upwind org only"
  }
  assert {
    condition     = google_service_account.cloudscanner_sa[0].account_id == "upwind-cs-zavca-r9i04vnj"
    error_message = "dev service accounts must keep the resource suffix"
  }
}

run "dev_role_id_suffix_moves_to_fresh_role_ids" {
  command = plan
  variables {
    is_dev         = true
    role_id_suffix = "b2"
  }

  assert {
    condition     = google_project_iam_custom_role.upwind_management_sa_cloudscanner_deployment_role[0].role_id == "CloudScannerDeploymentRole_zavca_b2"
    error_message = "dev role_id_suffix must be appended to the Upwind org"
  }
}

run "prod_ignores_role_id_suffix" {
  command = plan
  variables { role_id_suffix = "b2" }

  assert {
    condition     = google_project_iam_custom_role.upwind_management_sa_cloudscanner_deployment_role[0].role_id == "CloudScannerDeploymentRole_zavca_r9i04vnj"
    error_message = "prod role IDs must keep the resource suffix only"
  }
}
