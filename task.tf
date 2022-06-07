# Create two Cloudwatch Log Groups for the backup container
resource "aws_cloudwatch_log_group" "stdout" {
  name              = "${var.name}-s3-backup-stdout"
  retention_in_days = "7"
}

resource "aws_cloudwatch_log_group" "stderr" {
  name              = "${var.name}-s3-backup-stderr"
  retention_in_days = "7"
}

module "s3_backup_container_definition" {
  source = "github.com/mergermarket/tf_ecs_container_definition?ref=no-secrets"

  name   = "${var.name}-s3-backup"
  image  = var.docker_image
  cpu    = 512
  memory = 512

  container_env = merge(
    var.backup_env,
    {
      "LOGSPOUT_CLOUDWATCHLOGS_LOG_GROUP_STDOUT" = "${var.name}-s3-backup-stdout"
      "LOGSPOUT_CLOUDWATCHLOGS_LOG_GROUP_STDERR" = "${var.name}-s3-backup-stderr"
    },
  )

  metadata = var.metadata

  mountpoint = {
    sourceVolume  = "s3_backup_volume"
    containerPath = var.bind_container_path
    readOnly      = "false"
  }
}

module "s3_backup_taskdef" {
  source = "github.com/mergermarket/tf_ecs_task_definition_with_task_role?ref=pre-assume-role"

  family                = "${var.name}-s3-backup"
  container_definitions = [module.s3_backup_container_definition.rendered]

  policy = data.aws_iam_policy_document.s3_backup_policy.json

  volume = {
    name      = "s3_backup_volume"
    host_path = var.bind_host_path
  }
}

# Allow the task to sync files into the container
data "aws_iam_policy_document" "s3_backup_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
  }
}

