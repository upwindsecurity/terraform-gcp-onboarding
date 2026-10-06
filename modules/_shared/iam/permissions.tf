variable "deployment_permissions" {
  description = "List of IAM permissions for deployment operations."
  type        = list(string)
  default = [
    # Compute Engine resource creation permissions
    "compute.instanceTemplates.create",
    "compute.instanceTemplates.delete",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.useReadOnly",
    "compute.instanceGroupManagers.create",
    "compute.instanceGroupManagers.delete",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.update",
    "compute.instanceGroups.delete",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instances.setLabels",
    "compute.disks.create",
    "compute.disks.get",
    "compute.disks.delete",
    "compute.zones.list",
    # Networking resource creation permissions
    "compute.networks.create",
    "compute.networks.get",
    "compute.networks.updatePolicy",
    "compute.networks.delete",
    "compute.subnetworks.create",
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.delete",
    "compute.routers.create",
    "compute.routers.get",
    "compute.routers.update", # For creating NAT on the router
    "compute.routers.delete",
    "compute.firewalls.create",
    "compute.firewalls.get",
    "compute.firewalls.delete",
    # Cloud Run creation permissions
    "run.jobs.create",
    "run.jobs.get",
    "run.jobs.update",
    "run.jobs.delete",
    "run.operations.get",
    "run.operations.list",
    "run.executions.get",
    "run.executions.list",
    # Cloud Scheduler creation permissions
    "cloudscheduler.jobs.create",
    "cloudscheduler.jobs.get",
    "cloudscheduler.jobs.enable",
    "cloudscheduler.jobs.update", # Required to update an existing scanner schedule in place
    "cloudscheduler.jobs.delete",
    # IAM permissions for setting up project bindings
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    # Service Account reference permission
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.actAs", # Required to assign a service account to instances
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    # Required for Terraform to check operation status
    "compute.regionOperations.get",
    # Required basic service usage
    "serviceusage.services.use"
  ]
}

variable "cloudscanner_basic_permissions" {
  description = "List of IAM permissions for basic CloudScanner operations."
  type        = list(string)
  default = [
    # Basic permissions for CloudScanner operation
    "compute.disks.createSnapshot",
    "compute.disks.get",
    "compute.disks.list",
    "compute.instances.attachDisk",
    "compute.instances.detachDisk",
    "compute.instances.get",
    "compute.instances.list",
    "compute.snapshots.get",
    "compute.snapshots.setLabels",
    "compute.snapshots.useReadOnly",
    "compute.zoneOperations.get",
    "compute.globalOperations.get",
    "iam.serviceAccounts.actAs",
    "run.executions.list",
  ]
}

variable "cloudscanner_scaler_permissions" {
  description = "List of IAM permissions for CloudScanner Scaler operations."
  type        = list(string)
  default = [
    # Permissions for the CloudScanner Scaler
    "compute.instanceGroups.get",  # Required to query the status of the instance group. Should be constrained to CS MIGs.
    "compute.instanceGroups.list", # Required to query the status of the instance group. Should be constrained to CS MIGs.
    "compute.instanceGroups.update",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.list",
    "compute.instanceGroupManagers.update", # Required to change the target size and remove instances from instance group. Should be constrained to CS MIGs.
    "compute.zoneOperations.get",           # The internal implementation queries the zone operations when removing disks.
    "compute.globalOperations.get",         # The internal implementation queries the global operations when removing snapshots.
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.instances.delete",
  ]
}

variable "cloudscanner_secret_access_permissions" {
  description = "List of IAM permissions for CloudScanner secret access."
  type        = list(string)
  default = [
    # Permissions for accessing secrets in Secret Manager
    "secretmanager.versions.access",
    "secretmanager.versions.get",
    "secretmanager.versions.list",
    "secretmanager.secrets.get",
    "secretmanager.secrets.list",
  ]
}

variable "cloudscanner_instance_template_mgmt_permissions" {
  description = "List of IAM permissions for CloudScanner instance template management."
  type        = list(string)
  default = [
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.create",
    "compute.instanceTemplates.delete",
    "compute.instanceTemplates.useReadOnly",
  ]
}

variable "cloudscanner_instance_template_test_creation_permissions" {
  description = "List of IAM permissions for CloudScanner instance template test creation."
  type        = list(string)
  default = [
    "compute.instances.create",
    "compute.instances.setMetadata",
    "compute.instances.setLabels",
    "compute.disks.create",
  ]
}

variable "disk_writer_permissions" {
  description = "List of IAM permissions for disk writer role."
  type        = list(string)
  default = [
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.setLabels",
    "compute.disks.use",
  ]
}

variable "compute_service_agent_minimal_permissions" {
  description = "List of IAM permissions for minimal compute service agent role."
  type        = list(string)
  default = [
    "compute.disks.create",
    "compute.disks.use",
    "compute.instances.create",
    "compute.instances.use",
    "compute.instances.delete",
    "compute.instances.setLabels",
    "compute.instances.setTags",
    "compute.instances.setMetadata",
    "compute.instances.setServiceAccount",
    "compute.subnetworks.use",
    "compute.instanceGroups.update"
  ]
}

variable "storage_read_permissions" {
  description = "Override for storage read permissions included in Upwind custom roles. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}

variable "iam_read_role_permissions" {
  description = "Override for read-only IAM permissions included in Upwind custom roles. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}

variable "organization_iam_read_permissions" {
  description = "Override for organization IAM read permissions included in the Upwind operations role. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}

variable "snapshot_reader_permissions" {
  description = "Override for snapshot reader permissions included in the CloudScanner operations role. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}

variable "snapshot_creator_permissions" {
  description = "Override for snapshot creator permissions included in the CloudScanner operations role. Null uses modules/_shared/permissions. iam.serviceAccounts.actAs is still appended when enable_snapshot_act_as is true."
  type        = list(string)
  default     = null
}

variable "enable_snapshot_act_as" {
  description = <<-EOT
    Append iam.serviceAccounts.actAs to the CloudScanner operations role.

    Required to act as the target project's default Compute Engine service account
    when creating snapshot/scan resources. Without it, snapshot jobs may fail with
    "403: does not have access to service account '<project-number>-compute@developer...'".

    Enabled by default so snapshotting works out of the box. The permission is
    applied at the cloudscanner-operations role's binding scope — org-wide for the
    organization module, folder-wide for folder, per-project for multiproject. Set
    to false to opt out after reviewing that scope.
  EOT
  type        = bool
  default     = true
}

variable "snapshot_deleter_permissions" {
  description = "Override for snapshot deleter permissions. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}

variable "storage_object_reader_permissions" {
  description = "Override for storage object reader permissions included when DSPM scanning is enabled. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}

variable "cloud_run_permissions" {
  description = "Override for Cloud Run permissions included in the CloudScanner operations role. Null uses modules/_shared/permissions."
  type        = list(string)
  default     = null
}
