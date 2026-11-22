mock_provider "google" {}

override_resource {
  target          = google_service_account.upwind_management_sa
  override_during = plan
  values = {
    id    = "projects/orchestrator/serviceAccounts/upwind-mgmt-zavca-prod@orchestrator.iam.gserviceaccount.com"
    email = "upwind-mgmt-zavca-prod@orchestrator.iam.gserviceaccount.com"
  }
}

override_resource {
  target          = google_service_account.cloudlogs_sa
  override_during = plan
  values = {
    id    = "projects/orchestrator/serviceAccounts/upwind-logs-zavca-prod@orchestrator.iam.gserviceaccount.com"
    email = "upwind-logs-zavca-prod@orchestrator.iam.gserviceaccount.com"
  }
}

variables {
  upwind_organization_id              = "org_knNDkklPjw0zavca"
  upwind_client_id                    = "client"
  upwind_client_secret                = "secret"
  upwind_orchestrator_project         = "orchestrator"
  workload_identity_trusted_account   = "123456789012"
  google_service_account_display_name = "Upwind"
  enable_cloudscanners                = false
  resource_suffix                     = "prod"
}

run "cloudlogs_disabled_by_default" {
  command = plan

  assert {
    condition = (
      length(google_service_account.cloudlogs_sa) == 0 &&
      length(google_service_account_iam_member.management_can_impersonate_cloudlogs) == 0 &&
      output.cloudlogs_sa_email == null
    )
    error_message = "nothing for cloud logs should be created unless enable_cloudlogs is true"
  }
}

run "cloudlogs_creates_sa_impersonated_by_management" {
  command = plan

  variables {
    enable_cloudlogs = true
  }

  assert {
    condition = (
      google_service_account.cloudlogs_sa[0].project == "orchestrator" &&
      google_service_account.cloudlogs_sa[0].account_id == replace(google_service_account.upwind_management_sa.account_id, "upwind-mgmt-", "upwind-logs-") &&
      google_service_account.cloudlogs_sa[0].account_id == "upwind-logs-zavca-prod"
    )
    error_message = "the cloud logs SA must share the management SA's suffix in the orchestrator project"
  }
  assert {
    condition = (
      google_service_account_iam_member.management_can_impersonate_cloudlogs[0].service_account_id == "projects/orchestrator/serviceAccounts/upwind-logs-zavca-prod@orchestrator.iam.gserviceaccount.com" &&
      google_service_account_iam_member.management_can_impersonate_cloudlogs[0].role == "roles/iam.serviceAccountTokenCreator" &&
      google_service_account_iam_member.management_can_impersonate_cloudlogs[0].member == "serviceAccount:upwind-mgmt-zavca-prod@orchestrator.iam.gserviceaccount.com"
    )
    error_message = "the management SA must be able to impersonate the cloud logs SA"
  }
  assert {
    condition     = output.cloudlogs_sa_email == "upwind-logs-zavca-prod@orchestrator.iam.gserviceaccount.com"
    error_message = "cloudlogs_sa_email must expose the cloud logs SA email"
  }
  assert {
    condition     = sort(output.cloudlogs_read_permissions) == tolist(["logging.sinks.get", "monitoring.timeSeries.list"])
    error_message = "the cloud logs reader permissions must be exactly logging.sinks.get and monitoring.timeSeries.list"
  }
}
