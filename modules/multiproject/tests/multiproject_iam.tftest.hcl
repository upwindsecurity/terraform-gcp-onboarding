mock_provider "google" {}

override_resource {
  target          = module.iam.google_service_account.upwind_management_sa
  override_during = plan
  values = {
    id    = "projects/upwind-orchestrator/serviceAccounts/upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    email = "upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
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
  target_project_ids                = ["upwind-orchestrator", "workload-project"]

  # Skip secret versions: Terraform 1.11's mock provider fills their write-only values at plan and fails
  create_secret_versions   = false
  upwind_client_secret_id  = "upwind-client-secret-test"
  scanner_client_secret_id = "upwind-scanner-client-secret-test"
}

run "management_sa_gets_explicit_container_viewer" {
  command = plan

  assert {
    condition = { for k, m in google_project_iam_member.upwind_management_sa_container_viewer_role_member : k => [m.project, m.role, m.member] } == {
      "upwind-orchestrator" = ["upwind-orchestrator", "roles/container.viewer", "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"]
      "workload-project"    = ["workload-project", "roles/container.viewer", "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"]
    }
    error_message = "the management SA needs an explicit roles/container.viewer grant on every target project so GKE access survives replacing roles/viewer"
  }
}

run "cloudlogs_disabled_creates_nothing" {
  command = plan

  assert {
    condition = (
      length(google_project_iam_custom_role.upwind_cloudlogs_reader_role) == 0 &&
      length(google_project_iam_member.upwind_cloudlogs_sa_reader_role_member) == 0 &&
      output.upwind_cloudlogs_service_account_email == null
    )
    error_message = "nothing for cloud logs should be created unless enable_cloudlogs is true"
  }
}

run "cloudlogs_grants_reader_role_on_every_target_project" {
  command = plan

  variables {
    enable_cloudlogs = true
  }

  assert {
    condition = (
      sort(keys(google_project_iam_custom_role.upwind_cloudlogs_reader_role)) == tolist(["upwind-orchestrator", "workload-project"]) &&
      alltrue([for k, r in google_project_iam_custom_role.upwind_cloudlogs_reader_role : r.project == k && r.role_id == "UpwindCloudLogsReader_test"]) &&
      alltrue([for r in values(google_project_iam_custom_role.upwind_cloudlogs_reader_role) : sort(r.permissions) == tolist(["logging.sinks.get", "monitoring.timeSeries.list"])])
    )
    error_message = "the cloud logs reader role must hold exactly logging.sinks.get and monitoring.timeSeries.list"
  }
  assert {
    condition = { for k, m in google_project_iam_member.upwind_cloudlogs_sa_reader_role_member : k => [m.project, m.member] } == {
      for id in ["upwind-orchestrator", "workload-project"] : id => [id, "serviceAccount:upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"]
    }
    error_message = "the cloud logs reader role must be granted to the cloud logs SA on every target project"
  }
  assert {
    condition     = output.upwind_cloudlogs_service_account_email == "upwind-logs@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "the module must output the cloud logs SA email"
  }
}
