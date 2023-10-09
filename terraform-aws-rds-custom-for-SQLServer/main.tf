
#-------------------------------
# Database Subnet Group
#-------------------------------

resource "aws_db_subnet_group" "rdscustom" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = local.db_subnet_group_name != null ? local.db_subnet_group_name : null
  name_prefix = local.db_subnet_group_name != null ? null : "awsrdscustom"
  description = var.db_subnet_group_description
  subnet_ids  = local.private_subnet_ids
  tags        = var.tags
}


resource "aws_db_instance" "primary" {
  allocated_storage           = try(var.aws_db_instance_primary.allocated_storage, null)
  auto_minor_version_upgrade  = true
  apply_immediately           = try(var.aws_db_instance_primary.apply_immediately, null)
  availability_zone           = local.primary_placement_specified == true ? var.aws_db_instance_primary.availability_zone : local.private_subnet_azs[0]
  backup_retention_period     = try(var.aws_db_instance_primary.backup_retention_period, null)
  custom_iam_instance_profile = local.iam_instance_profile_name
  backup_window               = try(var.aws_db_instance_primary.backup_window, null)
  copy_tags_to_snapshot       = try(var.aws_db_instance_primary.copy_tags_to_snapshot, null)
  deletion_protection         = try(var.aws_db_instance_primary.deletion_protection, null) #tfsec:ignore:aws-rds-enable-deletion-protection
  db_name                     = try(var.aws_db_instance_primary.db_name, null)
  db_subnet_group_name        = local.db_subnet_group
  engine                      = try(var.aws_db_instance_primary.engine, null)
  engine_version              = try(var.aws_db_instance_primary.engine_version, null)
  final_snapshot_identifier   = try(var.aws_db_instance_primary.final_snapshot_identifier, null)
  identifier                  = try(var.aws_db_instance_primary.identifier, null)
  instance_class              = try(var.aws_db_instance_primary.instance_class, null)
  iops                        = try(var.aws_db_instance_primary.iops, null)
  kms_key_id                  = local.key_arn            # Resource requires an Arn, but the module accepts any KMS key Id
  maintenance_window          = try(var.aws_db_instance_primary.maintenance_window, null)
  network_type                = try(var.aws_db_instance_primary.network_type, null)
  multi_az                    = false
  password                    = try(var.aws_db_instance_primary.password, null)
  port                        = try(var.aws_db_instance_primary.port, null)
  publicly_accessible         = try(var.aws_db_instance_primary.publicly_accessible, null)
  skip_final_snapshot         = try(var.aws_db_instance_primary.skip_final_snapshot, null)
  storage_type                = try(var.aws_db_instance_primary.storage_type, null)
  storage_encrypted           = true # Required for RDS Custom for SQL Server
  username                    = try(var.aws_db_instance_primary.username, null)
  vpc_security_group_ids      = toset(try(var.aws_db_instance_primary.vpc_security_group_ids, null))
  tags                        = var.tags
  /*
  RDS instance creation and configuration requires that the VPC endpoints and IAM instance profile be created first.
  */
  depends_on = [
    module.private_link_endpoints
  ]

  timeouts {
    create = try(var.timeout.create, "4h")
    delete = try(var.timeout.delete, "4h")
    update = try(var.timeout.update, "4h")
  }
}

#-------------------------------
# Endpoints
#-------------------------------
module "private_link_endpoints" {
  source = "./modules/endpoints"

  count = var.create_vpc_endpoints ? 1 : 0

  vpc_id                         = var.vpc_id
  vpc_cidr                       = var.vpc_cidr
  private_subnet_ids             = local.private_subnet_ids
  private_subnet_route_table_ids = var.private_subnet_route_table_ids

  create_endpoint_security_group      = var.create_endpoint_security_group
  endpoint_security_group_name        = try(var.endpoint_security_group_name, null)
  endpoint_security_group_description = try(var.endpoint_security_group_description, null)
  endpoint_security_group_id          = try(var.endpoint_security_group_id, null)

  tags = var.tags
}
