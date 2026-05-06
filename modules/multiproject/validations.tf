# Upwind Credentials
check "upwind_credentials" {
  assert {
    condition     = var.upwind_client_id != null && var.upwind_client_id != ""
    error_message = "upwind_client_id cannot be null or empty."
  }
  assert {
    condition     = var.upwind_client_secret != null && var.upwind_client_secret != ""
    error_message = "upwind_client_secret cannot be null or empty."
  }
}

# Cloud Scanner Credentials
check "cloudscanner_credentials" {
  assert {
    condition     = var.scanner_client_id != null && var.scanner_client_id != ""
    error_message = "scanner_client_id cannot be null or empty."
  }
  assert {
    condition     = var.scanner_client_secret != null && var.scanner_client_secret != ""
    error_message = "scanner_client_secret cannot be null or empty."
  }
}
