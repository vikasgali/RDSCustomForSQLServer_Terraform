#-------------------------------
# Create IAM Instance Profile
#-------------------------------
resource "aws_iam_instance_profile" "rdscustom" {
  count = local.create_iam_instance_profile ? 1 : 0

  name        = var.iam_instance_profile_name != null ? var.iam_instance_profile_name : null
  name_prefix = var.iam_instance_profile_name == null ? "AWSRDSCustomInstanceProfile-" : null
  path        = var.iam_instance_profile_path
  role        = local.iam_role_name

  tags = var.tags
}


#-------------------------------
# Create IAM Role
#-------------------------------
resource "aws_iam_role" "rdscustom" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_name != null ? var.iam_role_name : null
  name_prefix = var.iam_role_name == null ? "AWSRDSCustomRole-" : null
  description = var.iam_role_description
  path        = var.iam_role_path
  tags        = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # SSM managed policy
  managed_policy_arns = [data.aws_iam_policy.ssm_managed_default_policy.arn]

  # policy that can write to cloudwatch logs, s3 and cloudwatchputdata
  inline_policy {
    name = "RDSCustomForSQLServer"
    policy = jsonencode({
      {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:ListAssociations",
                "ssm:PutInventory",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateInstanceInformation",
                "ssm:GetManifest"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ssmAgent1"
        },
        {
            "Condition": {
                "StringLike": {
                    "aws:ResourceTag/AWSRDSCustom": "custom-sqlserver"
                }
            },
            "Action": [
                "ssm:ListInstanceAssociations",
                "ssm:PutComplianceItems",
                "ssm:UpdateAssociationStatus",
                "ssm:DescribeAssociation",
                "ssm:UpdateInstanceAssociationStatus"
            ],
            "Resource": "arn:aws:ec2:us-east-2:766386211122:instance/*",
            "Effect": "Allow",
            "Sid": "ssmAgent2"
        },
        {
            "Action": [
                "ssm:UpdateAssociationStatus",
                "ssm:DescribeAssociation",
                "ssm:GetDocument",
                "ssm:DescribeDocument"
            ],
            "Resource": "arn:aws:ssm:*:*:document/*",
            "Effect": "Allow",
            "Sid": "ssmAgent3"
        },
        {
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ssmAgent4"
        },
        {
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ssmAgent5"
        },
        {
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/*",
            "Effect": "Allow",
            "Sid": "ssmAgent6"
        },
        {
            "Action": [
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:DescribeAssociation"
            ],
            "Resource": "arn:aws:ssm:*:*:association/*",
            "Effect": "Allow",
            "Sid": "ssmAgent7"
        },
        {
            "Condition": {
                "StringLike": {
                    "aws:ResourceTag/AWSRDSCustom": "custom-sqlserver"
                }
            },
            "Action": "ec2:CreateSnapshot",
            "Resource": [
                "arn:aws:ec2:us-east-2:766386211122:volume/*"
            ],
            "Effect": "Allow",
            "Sid": "eccSnapshot1"
        },
        {
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/AWSRDSCustom": "custom-sqlserver"
                }
            },
            "Action": "ec2:CreateSnapshot",
            "Resource": [
                "arn:aws:ec2:us-east-2::snapshot/*"
            ],
            "Effect": "Allow",
            "Sid": "eccSnapshot2"
        },
        {
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/AWSRDSCustom": "custom-sqlserver",
                    "ec2:CreateAction": [
                        "CreateSnapshot"
                    ]
                }
            },
            "Action": "ec2:CreateTags",
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "eccCreateTag"
        },
        {
            "Action": [
                "s3:putObject",
                "s3:getObject",
                "s3:getObjectVersion",
                "s3:AbortMultipartUpload"
            ],
            "Resource": [
                "arn:aws:s3:::do-not-delete-rds-custom-*/*"
            ],
            "Effect": "Allow",
            "Sid": "s3BucketAccess"
        },
        {
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": [
                "arn:aws:kms:us-east-2:766386211122:key/4cb59935-28c1-4644-8e24-ed1886c5313f"
            ],
            "Effect": "Allow",
            "Sid": "customerCMKEncryption"
        },
        {
            "Condition": {
                "StringLike": {
                    "aws:ResourceTag/AWSRDSCustom": "custom-sqlserver"
                }
            },
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-east-2:766386211122:secret:do-not-delete-rds-custom-*"
            ],
            "Effect": "Allow",
            "Sid": "readSecretsFromCP"
        },
        {
            "Condition": {
                "StringEquals": {
                    "cloudwatch:namespace": "rdscustom/rds-custom-sqlserver-agent"
                }
            },
            "Action": "cloudwatch:PutMetricData",
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "publishCWMetrics"
        },
        {
            "Action": "events:PutEvents",
            "Resource": "arn:aws:events:us-east-2:766386211122:event-bus/default",
            "Effect": "Allow",
            "Sid": "putEventsToEventBus"
        },
        {
            "Action": [
                "logs:PutRetentionPolicy",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "arn:aws:logs:us-east-2:766386211122:log-group:rds-custom-instance-*",
            "Effect": "Allow",
            "Sid": "cwlOperations1"
        },
        {
            "Action": "logs:DescribeLogGroups",
            "Resource": "arn:aws:logs:us-east-2:766386211122:log-group:*",
            "Effect": "Allow",
            "Sid": "cwlOperations2"
        },
        {
            "Condition": {
                "StringLike": {
                    "aws:ResourceTag/AWSRDSCustom": "custom-sqlserver"
                }
            },
            "Action": [
                "SQS:SendMessage",
                "SQS:ReceiveMessage",
                "SQS:DeleteMessage",
                "SQS:GetQueueUrl"
            ],
            "Resource": [
                "arn:aws:sqs:us-east-2:766386211122:do-not-delete-rds-custom-*"
            ],
            "Effect": "Allow",
            "Sid": "SendMessageToSQSQueue"
        }
    ]
}
}
}
}
