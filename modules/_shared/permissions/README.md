# Shared permission lists

Canonical IAM permission lists for the organization roles used by onboarding and by `modules/organization-iam`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_run_permissions"></a> [cloud\_run\_permissions](#output\_cloud\_run\_permissions) | IAM permissions for Cloud Run artifact access. |
| <a name="output_iam_read_role_permissions"></a> [iam\_read\_role\_permissions](#output\_iam\_read\_role\_permissions) | IAM permissions for read-only access across GCP services. |
| <a name="output_organization_iam_read_permissions"></a> [organization\_iam\_read\_permissions](#output\_organization\_iam\_read\_permissions) | IAM permissions for reading the organization IAM policy. |
| <a name="output_snapshot_creator_permissions"></a> [snapshot\_creator\_permissions](#output\_snapshot\_creator\_permissions) | IAM permissions for creating snapshots and scan resources in target projects. Does not include iam.serviceAccounts.actAs; callers append that when enable\_snapshot\_act\_as is true. |
| <a name="output_snapshot_deleter_permissions"></a> [snapshot\_deleter\_permissions](#output\_snapshot\_deleter\_permissions) | IAM permissions for deleting snapshots. |
| <a name="output_snapshot_reader_permissions"></a> [snapshot\_reader\_permissions](#output\_snapshot\_reader\_permissions) | IAM permissions for reading snapshots. |
| <a name="output_storage_object_reader_permissions"></a> [storage\_object\_reader\_permissions](#output\_storage\_object\_reader\_permissions) | IAM permissions for storage object read access. |
| <a name="output_storage_read_permissions"></a> [storage\_read\_permissions](#output\_storage\_read\_permissions) | IAM permissions for storage read access. |
<!-- END_TF_DOCS -->
