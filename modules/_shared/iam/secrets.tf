### Secrets used by Cloudscanners

locals {
  # Resolves to whichever secret is actually in play for each credential - the one this
  # module created, or the customer's pre-existing secret - so downstream IAM grants and
  # the upwind-configuration pointer secret don't need to care which case they're in.
  upwind_client_secret_ref = var.upwind_client_secret_id == "" ? google_secret_manager_secret.upwind_client_secret[0] : data.google_secret_manager_secret.upwind_client_secret_existing[0]

  scanner_client_secret_ref = var.enable_cloudscanners ? (
    var.scanner_client_secret_id == "" ? google_secret_manager_secret.scanner_client_secret[0] : data.google_secret_manager_secret.scanner_client_secret_existing[0]
  ) : null
}

resource "google_secret_manager_secret" "upwind_client_id" {
  secret_id = "upwind-client-id-${local.resource_suffix_hyphen}"
  project   = local.project
  replication {
    dynamic "auto" {
      for_each = length(var.secret_replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(var.secret_replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.secret_replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret" "upwind_client_secret" {
  count     = var.upwind_client_secret_id == "" ? 1 : 0
  secret_id = "upwind-client-secret-${local.resource_suffix_hyphen}"
  project   = local.project
  replication {
    dynamic "auto" {
      for_each = length(var.secret_replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(var.secret_replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.secret_replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

# Referenced (not created/managed) when the customer already has this secret populated,
# so the Terraform identity applying this module never needs secretmanager.versions.add on it.
data "google_secret_manager_secret" "upwind_client_secret_existing" {
  count     = var.upwind_client_secret_id != "" ? 1 : 0
  secret_id = var.upwind_client_secret_id
  project   = local.project
}

resource "google_secret_manager_secret" "scanner_client_id" {
  count     = var.enable_cloudscanners ? 1 : 0
  secret_id = "upwind-scanner-client-id-${local.resource_suffix_hyphen}"
  project   = local.project
  replication {
    dynamic "auto" {
      for_each = length(var.secret_replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(var.secret_replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.secret_replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret" "scanner_client_secret" {
  count     = var.enable_cloudscanners && var.scanner_client_secret_id == "" ? 1 : 0
  secret_id = "upwind-scanner-client-secret-${local.resource_suffix_hyphen}"
  project   = local.project
  replication {
    dynamic "auto" {
      for_each = length(var.secret_replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(var.secret_replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.secret_replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

# Referenced (not created/managed) when the customer already has this secret populated,
# so the Terraform identity applying this module never needs secretmanager.versions.add on it.
data "google_secret_manager_secret" "scanner_client_secret_existing" {
  count     = var.enable_cloudscanners && var.scanner_client_secret_id != "" ? 1 : 0
  secret_id = var.scanner_client_secret_id
  project   = local.project
}

# Create an empty secret but apply the user-defined labels to the resource
resource "google_secret_manager_secret" "terraform_labels" {
  secret_id = "upwind-default-labels-${local.resource_suffix_hyphen}"
  project   = local.project

  replication {
    dynamic "auto" {
      for_each = length(var.secret_replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(var.secret_replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.secret_replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "upwind_client_id_v1" {
  secret         = google_secret_manager_secret.upwind_client_id.id
  secret_data_wo = var.upwind_client_id
}

resource "google_secret_manager_secret_version" "upwind_client_secret_v1" {
  count          = var.upwind_client_secret_id == "" ? 1 : 0
  secret         = google_secret_manager_secret.upwind_client_secret[0].id
  secret_data_wo = var.upwind_client_secret
}

resource "google_secret_manager_secret_version" "scanner_client_id_v1" {
  count          = var.enable_cloudscanners ? 1 : 0
  secret         = google_secret_manager_secret.scanner_client_id[0].id
  secret_data_wo = var.scanner_client_id
}

resource "google_secret_manager_secret_version" "scanner_client_secret_v1" {
  count          = var.enable_cloudscanners && var.scanner_client_secret_id == "" ? 1 : 0
  secret         = google_secret_manager_secret.scanner_client_secret[0].id
  secret_data_wo = var.scanner_client_secret
}

resource "google_secret_manager_secret_version" "terraform_labels_v1" {
  secret         = google_secret_manager_secret.terraform_labels.id
  secret_data_wo = "labels-stored-as-resource-metadata"
}

# Pointer/config secret: tracks the Upwind + Cloudscanner client IDs and the *names* of the
# secrets holding their client secrets (never the secret values themselves), regardless of
# whether this module created those secrets or the customer supplied pre-existing ones. This
# is what lets discovery move beyond the fixed naming convention later without a breaking
# change - a consumer only ever needs to find this one well-known secret.
resource "google_secret_manager_secret" "upwind_configuration" {
  secret_id = "upwind-configuration-${local.resource_suffix_hyphen}"
  project   = local.project

  replication {
    dynamic "auto" {
      for_each = length(var.secret_replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(var.secret_replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.secret_replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

locals {
  upwind_configuration_payload = {
    # Bump whenever this payload's shape changes, so consumers can tell old configs from new
    # ones instead of guessing from which fields happen to be present.
    schema_version = 1

    upwind_organization_id = var.upwind_organization_id
    resource_suffix_hyphen = local.resource_suffix_hyphen

    enable_cloudscanners = var.enable_cloudscanners
    enable_dspm_scanning = var.enable_dspm_scanning

    upwind_client_id           = var.upwind_client_id
    upwind_client_secret_name  = local.upwind_client_secret_ref.secret_id
    scanner_client_id          = var.enable_cloudscanners ? var.scanner_client_id : null
    scanner_client_secret_name = var.enable_cloudscanners ? local.scanner_client_secret_ref.secret_id : null

    upwind_management_sa_email   = google_service_account.upwind_management_sa.email
    cloudscanner_sa_email        = var.enable_cloudscanners ? google_service_account.cloudscanner_sa[0].email : null
    cloudscanner_scaler_sa_email = var.enable_cloudscanners ? google_service_account.cloudscanner_scaler_sa[0].email : null

    workload_identity_pool_project  = var.workload_identity_pool_project == "" ? local.project : var.workload_identity_pool_project
    workload_identity_provider_name = google_iam_workload_identity_pool_provider.aws.name
  }

  # secret_data_wo is a write-only attribute, so Terraform never diffs it - without an explicit
  # version bump on every content change, edits to the payload above would silently never get
  # written to an already-existing secret. Deriving the version from a hash of the payload makes
  # that automatic instead of relying on someone remembering to bump a counter by hand.
  upwind_configuration_version = parseint(substr(md5(jsonencode(local.upwind_configuration_payload)), 0, 8), 16)
}

resource "google_secret_manager_secret_version" "upwind_configuration_v1" {
  secret                 = google_secret_manager_secret.upwind_configuration.id
  secret_data_wo         = jsonencode(local.upwind_configuration_payload)
  secret_data_wo_version = local.upwind_configuration_version
}
