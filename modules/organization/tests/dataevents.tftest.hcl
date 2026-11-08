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

  # Skip secret versions: Terraform 1.11's mock provider fills their write-only values at plan and fails
  create_secret_versions   = false
  upwind_client_secret_id  = "upwind-client-secret-test"
  scanner_client_secret_id = "upwind-scanner-client-secret-test"
}

run "dataevents_off_by_default" {
  command = plan

  assert {
    condition     = length(google_organization_iam_custom_role.upwind_management_sa_dataevents_role) == 0
    error_message = "the data-events role should not be created unless enable_dataevents is set"
  }
  assert {
    condition     = length(google_organization_iam_member.upwind_management_sa_dataevents_role_member) == 0
    error_message = "the data-events role should not be granted unless enable_dataevents is set"
  }
}

run "dataevents_grants_the_management_service_account" {
  command = plan

  variables {
    enable_dataevents = true
  }

  assert {
    condition     = toset(google_organization_iam_custom_role.upwind_management_sa_dataevents_role[0].permissions) == toset(["pubsub.subscriptions.consume", "storage.objects.get"])
    error_message = "the data-events role should hold only the Pub/Sub consume and object read permissions"
  }
  assert {
    condition     = google_organization_iam_member.upwind_management_sa_dataevents_role_member[0].member == "serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "the data-events role should be granted to the management service account"
  }
}
