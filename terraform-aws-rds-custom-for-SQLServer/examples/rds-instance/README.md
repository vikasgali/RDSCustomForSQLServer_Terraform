<!-- BEGIN_TF_DOCS -->
# Creating primary RDS Custom for Oracle instance in a VPC

This example shows how you can create a primary instance in your Amazon VPC. This example creates the following:

* RDS Custom for Oracle primary instance using a precreated Custom Engine Version (CEV)
* VPC with two private subnets (two subnets are required for a DBSubnet Group).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds_custom_for_oracle"></a> [rds\_custom\_for\_oracle](#module\_rds\_custom\_for\_oracle) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | aws-ia/vpc/aws | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_rds_orderable_db_instance.custom-oracle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_orderable_db_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_key_id_for_cev"></a> [kms\_key\_id\_for\_cev](#input\_kms\_key\_id\_for\_cev) | KMS key associated with the CEV | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_db_instance_primary_arn"></a> [aws\_db\_instance\_primary\_arn](#output\_aws\_db\_instance\_primary\_arn) | Created RDS primary instance arn. |
| <a name="output_db_subnet_group"></a> [db\_subnet\_group](#output\_db\_subnet\_group) | Created RDS DB subnet group. |
| <a name="output_subnet_config"></a> [subnet\_config](#output\_subnet\_config) | Created subnets. |
<!-- END_TF_DOCS -->