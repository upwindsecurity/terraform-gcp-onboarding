# Google Cloud Organization IAM Module

Applies the organization custom roles and organization IAM bindings for an Upwind organization onboarding. Use this when the identity that runs [`modules/organization`](../organization) cannot create organization roles or set the organization IAM policy.

Set `manage_organization_iam = false` on the organization module. That apply still creates the management service account, Workload Identity, secrets, and orchestrator-project IAM. This module then grants, on the GCP organization:

- `roles/viewer`
- `roles/resourcemanager.folderViewer`
- `roles/cloudasset.viewer`
- the Upwind operations custom role

When Cloud Scanners are enabled it also creates the CloudScanner operations and snapshot-deleter roles and grants `roles/compute.viewer`. When DSPM scanning is enabled it creates a separate object-reader role. Scanner grants use `google_organization_iam_member` (additive) rather than an authoritative binding.

`gcp_organization_id`, `upwind_organization_id`, `resource_suffix`, `enable_cloudscanners`, `enable_dspm_scanning`, and `enable_snapshot_act_as` must match the organization module. Role IDs are derived from the Upwind organization ID and suffix. Pass service account emails from the organization module outputs.

Apply the organization module first so the service accounts exist, then apply this module.

## Moving grants that already exist

Upgrading the organization module with `manage_organization_iam` left at `true` only moves state to a count index. Do that apply before splitting.

Then, in this module's state, import the existing roles and members. In the organization module's state, `terraform state rm` the same objects. `state rm` drops them from that state and does not delete them in GCP. Set `manage_organization_iam = false` only after they are gone from the organization state. If that plan still shows destroys, stop.

Deleting a custom role reserves its role ID for several days, so destroying here and recreating in this module will fail. Import, then `state rm`.

```bash
# Custom role. ROLE_ID is the organization module output organization_iam.operations_role_id.
terraform import google_organization_iam_custom_role.upwind_management_sa_operations_role ORG_ID/roles/ROLE_ID

terraform import google_organization_iam_member.upwind_management_sa_org_viewer_role_member "ORG_ID roles/viewer serviceAccount:SA_EMAIL"
terraform import google_organization_iam_member.upwind_management_sa_folder_viewer_role_member "ORG_ID roles/resourcemanager.folderViewer serviceAccount:SA_EMAIL"
terraform import google_organization_iam_member.upwind_management_sa_operations_role_member "ORG_ID organizations/ORG_ID/roles/ROLE_ID serviceAccount:SA_EMAIL"
terraform import google_organization_iam_member.upwind_management_sa_asset_viewer_role_member "ORG_ID roles/cloudasset.viewer serviceAccount:SA_EMAIL"
```

Cloud Scanner roles follow the same import shape. Import each scanner member, including the snapshot-deleter condition title `Upwind Cloud Scanner Snapshot Deleter`. Then `state rm` these addresses from the organization state:

- `google_organization_iam_custom_role.upwind_management_sa_operations_role[0]`
- `google_organization_iam_member.upwind_management_sa_org_viewer_role_member[0]`
- `google_organization_iam_member.upwind_management_sa_folder_viewer_role_member[0]`
- `google_organization_iam_member.upwind_management_sa_operations_role_member[0]`
- `google_organization_iam_member.upwind_management_sa_asset_viewer_role_member[0]`
- `google_organization_iam_custom_role.upwind_cloudscanner_operations_role[0]`
- `google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role[0]`
- `google_organization_iam_member.upwind_cloudscanner_sa_compute_viewer_role_member[0]`
- `google_organization_iam_binding.upwind_cloudscanner_operations_role_binding[0]`
- `google_organization_iam_binding.upwind_cloudscanner_snapshot_deleter_role_binding[0]`
- `google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role[0]`
- `google_organization_iam_binding.upwind_cloudscanner_object_reader_role_binding[0]`

Orchestrator-project IAM stays in the organization module.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.23.0, < 9.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.23.0, < 9.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_permissions"></a> [permissions](#module\_permissions) | ../_shared/permissions | n/a |

## Resources

| Name | Type |
|------|------|
| [google_organization_iam_custom_role.upwind_cloudscanner_object_reader_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_custom_role.upwind_cloudscanner_operations_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_custom_role.upwind_cloudscanner_snapshot_deleter_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_custom_role.upwind_management_sa_operations_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.upwind_cloudscanner_sa_compute_viewer_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_cloudscanner_sa_object_reader_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_cloudscanner_sa_operations_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_cloudscanner_sa_snapshot_deleter_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_cloudscanner_scaler_sa_operations_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_cloudscanner_scaler_sa_snapshot_deleter_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_management_sa_asset_viewer_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_management_sa_folder_viewer_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_management_sa_operations_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.upwind_management_sa_org_viewer_role_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudscanner_sa_email"></a> [cloudscanner\_sa\_email](#input\_cloudscanner\_sa\_email) | Email of the CloudScanner service account created by the organization module. Required when enable\_cloudscanners is true. | `string` | `""` | no |
| <a name="input_cloudscanner_scaler_sa_email"></a> [cloudscanner\_scaler\_sa\_email](#input\_cloudscanner\_scaler\_sa\_email) | Email of the CloudScanner scaler service account created by the organization module. Required when enable\_cloudscanners is true. | `string` | `""` | no |
| <a name="input_enable_cloudscanners"></a> [enable\_cloudscanners](#input\_enable\_cloudscanners) | Create the CloudScanner organization roles and bindings. Must match enable\_cloudscanners on the organization module. | `bool` | `false` | no |
| <a name="input_enable_dspm_scanning"></a> [enable\_dspm\_scanning](#input\_enable\_dspm\_scanning) | Include storage object read permissions on the CloudScanner operations role. Must match the organization module. Only applies when enable\_cloudscanners is true. | `bool` | `false` | no |
| <a name="input_enable_snapshot_act_as"></a> [enable\_snapshot\_act\_as](#input\_enable\_snapshot\_act\_as) | Append iam.serviceAccounts.actAs to the CloudScanner operations role so snapshot jobs can act as the target project's default Compute Engine service account. Must match the organization module. | `bool` | `true` | no |
| <a name="input_gcp_organization_id"></a> [gcp\_organization\_id](#input\_gcp\_organization\_id) | The GCP organization ID. Must match the organization module. | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | The suffix appended to custom role IDs. Must match the organization module, including an empty suffix. | `string` | `""` | no |
| <a name="input_upwind_management_sa_email"></a> [upwind\_management\_sa\_email](#input\_upwind\_management\_sa\_email) | Email of the Upwind management service account created by the organization module. | `string` | n/a | yes |
| <a name="input_upwind_organization_id"></a> [upwind\_organization\_id](#input\_upwind\_organization\_id) | The identifier of the Upwind organization to integrate with. Must match the organization module. Used only to derive custom role IDs. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudscanner_object_reader_role_id"></a> [cloudscanner\_object\_reader\_role\_id](#output\_cloudscanner\_object\_reader\_role\_id) | ID of the CloudScanner object reader custom role. Null unless cloud scanners and DSPM scanning are enabled. |
| <a name="output_cloudscanner_operations_role_id"></a> [cloudscanner\_operations\_role\_id](#output\_cloudscanner\_operations\_role\_id) | ID of the CloudScanner operations custom role. Null when cloud scanners are disabled. |
| <a name="output_cloudscanner_snapshot_deleter_role_id"></a> [cloudscanner\_snapshot\_deleter\_role\_id](#output\_cloudscanner\_snapshot\_deleter\_role\_id) | ID of the CloudScanner snapshot deleter custom role. Null when cloud scanners are disabled. |
| <a name="output_operations_role_id"></a> [operations\_role\_id](#output\_operations\_role\_id) | ID of the Upwind management operations custom role. |
| <a name="output_operations_role_name"></a> [operations\_role\_name](#output\_operations\_role\_name) | Full resource name of the Upwind management operations custom role. |
<!-- END_TF_DOCS -->
