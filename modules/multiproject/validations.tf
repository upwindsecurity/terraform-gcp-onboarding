resource "terraform_data" "validate_cloudscanner_credentials" {
  lifecycle {
    precondition {
      condition     = !var.enable_cloudscanners || (var.scanner_client_id != "" && (var.scanner_client_secret != "" || var.scanner_client_secret_id != ""))
      error_message = "When enable_cloudscanners is true, scanner_client_id must be provided along with either scanner_client_secret or scanner_client_secret_id."
    }
  }
}
