locals {
  storage_read_permissions = [
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.getIpFilter",
    "storage.buckets.list",
    "storage.buckets.listEffectiveTags",
    "storage.buckets.listTagBindings",
    "storage.bucketOperations.get",
    "storage.bucketOperations.list",
    "storage.folders.get",
    "storage.folders.list",
    "storage.managedFolders.get",
    "storage.managedFolders.getIamPolicy",
    "storage.managedFolders.list",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
  ]

  iam_read_role_permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "resourcemanager.projects.getIamPolicy",
    "iam.roles.get",
    "iam.roles.list",
  ]

  organization_iam_read_permissions = [
    "resourcemanager.organizations.getIamPolicy",
    "iam.workloadIdentityPoolProviders.get",
  ]

  snapshot_reader_permissions = [
    "compute.disks.get",
    "compute.disks.list",
    "compute.disks.createSnapshot", # Cannot be restricted, we don't know target disk names
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.instances.get",
    "compute.instances.list",
    "compute.diskTypes.get",
    "compute.diskTypes.list",
    "compute.projects.get",
    "resourcemanager.projects.get",
    "compute.zoneOperations.get",
    "compute.globalOperations.get",
    "compute.regionOperations.get",
  ]

  snapshot_creator_permissions = [
    "compute.snapshots.create",
    "compute.snapshots.setLabels",
    "compute.snapshots.useReadOnly",
  ]

  snapshot_deleter_permissions = [
    "compute.snapshots.delete",
  ]

  storage_object_reader_permissions = [
    "storage.objects.get",
    "storage.buckets.get",
    "storage.buckets.list",
  ]

  cloud_run_permissions = [
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.dockerimages.get",
  ]
}
