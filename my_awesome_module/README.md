<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_with_oidc"></a> [iam\_assumable\_role\_with\_oidc](#module\_iam\_assumable\_role\_with\_oidc) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.the_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name | `string` | `""` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of permissions to attach to the IAM role | `list` | `[]` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | IAM role name | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_the_bucket"></a> [the\_bucket](#output\_the\_bucket) | n/a |
| <a name="output_the_role"></a> [the\_role](#output\_the\_role) | n/a |
<!-- END_TF_DOCS -->