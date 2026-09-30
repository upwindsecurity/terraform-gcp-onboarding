mock_provider "google" {}
mock_provider "http" {
  mock_data "http" {
    defaults = {
      status_code   = 200
      response_body = "{\"access_token\":\"test-token\"}"
    }
  }
}

variables {
  upwind_organization_id   = "org_test"
  upwind_client_id         = "client"
  upwind_client_secret     = "secret"
  skip_deprecation_warning = true
}

run "us_uses_base_endpoints" {
  command = plan
  variables { upwind_region = "us" }

  assert {
    condition     = data.http.upwind_get_access_token_request[0].url == "https://auth.upwind.io/oauth/token"
    error_message = "unexpected auth URL"
  }
  assert {
    condition     = data.http.upwind_create_credentials_request[0].url == "https://integration.upwind.io/v1/organizations/org_test/set-credentials"
    error_message = "unexpected integration URL"
  }
}

run "pdc_region_inserted_into_endpoints" {
  command = plan
  variables { upwind_region = "pdc07" }

  assert {
    condition     = data.http.upwind_get_access_token_request[0].url == "https://auth.pdc07.upwind.io/oauth/token"
    error_message = "unexpected auth URL"
  }
  assert {
    condition     = strcontains(data.http.upwind_get_access_token_request[0].request_body, "audience=https://integration.pdc07.upwind.io")
    error_message = "unexpected audience"
  }
  assert {
    condition     = data.http.upwind_create_credentials_request[0].url == "https://integration.pdc07.upwind.io/v1/organizations/org_test/set-credentials"
    error_message = "unexpected integration URL"
  }
}

run "rejects_bad_pdc_format" {
  command = plan
  variables { upwind_region = "pdc1" }
  expect_failures = [var.upwind_region]
}
