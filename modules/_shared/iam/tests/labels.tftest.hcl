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
  labels                              = { owner = "platform-security", managed_by = "acme" }
}

run "labels_secret_carries_merged_labels" {
  command = plan

  assert {
    condition = google_secret_manager_secret.terraform_labels[0].labels == tomap({
      component  = "upwind"
      managed_by = "acme"
      owner      = "platform-security"
    })
    error_message = "labels secret must carry default labels overridden by user labels"
  }
}

run "all_secrets_are_labelled" {
  command = plan

  assert {
    condition = alltrue([
      google_secret_manager_secret.upwind_client_id[0].labels["owner"] == "platform-security",
      google_secret_manager_secret.upwind_client_secret[0].labels["owner"] == "platform-security",
      google_secret_manager_secret.scanner_client_id[0].labels["owner"] == "platform-security",
      google_secret_manager_secret.scanner_client_secret[0].labels["owner"] == "platform-security",
      google_secret_manager_secret.upwind_configuration.labels["owner"] == "platform-security",
    ])
    error_message = "every Upwind secret must carry the user labels"
  }
}

run "saas_omits_labels_secret" {
  command = plan

  variables {
    is_saas                        = true
    workload_identity_saas_subject = "123456789012345678901"
  }

  assert {
    condition = (
      length(google_secret_manager_secret.terraform_labels) == 0 &&
      length(google_secret_manager_secret_version.terraform_labels_v1) == 0 &&
      length(google_secret_manager_secret_iam_member.terraform_labels_viewer) == 0
    )
    error_message = "SaaS mode should not create the labels secret, its version or its viewer grant"
  }
}
