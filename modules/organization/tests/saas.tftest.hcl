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

run "outpost_deploys_scanner_infrastructure" {
  command = plan

  assert {
    condition     = module.iam.cloudscanner_scaler_sa != null
    error_message = "outpost mode should create the scaler service account"
  }
  assert {
    condition     = module.iam.google_project_iam_member.upwind_management_sa_cloudscanner_deployment_role_member != null
    error_message = "outpost mode should grant the deployment role"
  }
  assert {
    condition     = module.iam.google_iam_workload_identity_pool_provider_saas == null
    error_message = "outpost mode should not create the SaaS provider"
  }
  assert {
    condition     = length(google_organization_iam_binding.upwind_cloudscanner_operations_role_binding[0].members) == 2
    error_message = "outpost mode should grant operations to the scanner and scaler service accounts"
  }
  assert {
    condition     = module.iam.cloudscanner_identity_email == "upwind-cs@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "outpost mode should publish the CloudScanner service account as the scanner identity"
  }
}

run "saas_omits_scanner_infrastructure" {
  command = plan

  variables {
    is_saas                        = true
    workload_identity_saas_subject = "123456789012345678901"

    # Upwind holds the hosted scanners' credentials, so SaaS mode takes none
    scanner_client_id        = ""
    scanner_client_secret_id = ""
  }

  assert {
    condition     = module.iam.cloudscanner_sa == null
    error_message = "SaaS mode should not create the CloudScanner service account"
  }
  assert {
    condition     = module.iam.cloudscanner_scaler_sa == null
    error_message = "SaaS mode should not create the scaler service account"
  }
  assert {
    condition     = alltrue([for role in values(module.iam.google_project_iam_custom_role) : role == null])
    error_message = "SaaS mode should create no project roles"
  }
  assert {
    condition     = module.iam.google_secret_manager_secret.scanner_client_id == null && module.iam.google_secret_manager_secret.scanner_client_secret == null
    error_message = "SaaS mode should not create the scanner credential secrets"
  }
  assert {
    condition     = google_organization_iam_binding.upwind_cloudscanner_operations_role_binding[0].members == toset(["serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"])
    error_message = "SaaS mode should grant operations to the management service account only"
  }
  assert {
    condition     = google_organization_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding[0].members == toset(["serviceAccount:upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"])
    error_message = "SaaS mode should grant snapshot deletion to the management service account only"
  }
  assert {
    condition     = !contains(google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0].permissions, "iam.serviceAccounts.actAs")
    error_message = "SaaS mode should not grant actAs"
  }
  assert {
    condition     = module.iam.cloudscanner_identity_email == "upwind-mgmt@upwind-orchestrator.iam.gserviceaccount.com"
    error_message = "SaaS mode should publish the management service account as the scanner identity"
  }
  assert {
    condition     = module.iam.google_iam_workload_identity_pool_provider_saas.workload_identity_pool_provider_id == "upwind-saas-gcp"
    error_message = "SaaS provider must use the name the hosted CloudScanner worker expects"
  }
  assert {
    condition     = module.iam.google_iam_workload_identity_pool_provider_saas.oidc[0].issuer_uri == "https://accounts.google.com"
    error_message = "SaaS provider should trust Google-issued ID tokens"
  }
  assert {
    condition     = module.iam.google_iam_workload_identity_pool_provider_saas.attribute_condition == "assertion.sub == '123456789012345678901'"
    error_message = "SaaS provider should only accept the Upwind scanner subject"
  }
}
