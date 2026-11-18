mock_provider "google" {}

override_resource {
  target          = module.iam.google_service_account.upwind_management_sa
  override_during = plan
  values = {
    id    = "projects/upwind-orchestrator/serviceAccounts/upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    email = "upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
  }
}

variables {
  upwind_organization_id            = "org_test"
  upwind_client_id                  = "client"
  scanner_client_id                 = "scanner"
  gcp_organization_id               = "123456789012"
  upwind_orchestrator_project       = "upwind-orchestrator"
  workload_identity_trusted_account = "111111111111"
  target_folder_ids                 = ["111111111111", "222222222222"]

  # Skip secret versions: Terraform 1.11's mock provider fills their write-only values at plan and fails
  create_secret_versions   = false
  upwind_client_secret_id  = "upwind-client-secret-test"
  scanner_client_secret_id = "upwind-scanner-client-secret-test"
}

run "management_sa_gets_explicit_container_viewer" {
  command = plan

  assert {
    condition = { for k, m in google_folder_iam_member.upwind_management_sa_container_viewer_role_member : k => [m.folder, m.role, m.member] } == {
      "111111111111" = ["111111111111", "roles/container.viewer", "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"]
      "222222222222" = ["222222222222", "roles/container.viewer", "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"]
    }
    error_message = "the management SA needs an explicit roles/container.viewer grant on every target folder so GKE access survives replacing roles/viewer"
  }
}
