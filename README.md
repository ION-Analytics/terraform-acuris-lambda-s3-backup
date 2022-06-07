`tf_lambda_s3_backup`
---------------------

This modules allows configure a ECS task with a given container to be triggered using
a cron expression.

Currently is designed to trigger backups using the container: https://github.com/mergermarket/docker-mysql-s3-backup,
but it would be adapted to run any container.

*Note*: since the release of [scheduled ECS tasks from AWS](https://aws.amazon.com/about-aws/whats-new/2017/06/amazon-ecs-now-supports-time-and-event-based-task-scheduling), there is no point to use a lambda for this anymore. But the code related to tasks can be reused.

Usage:
-----

You can configure it with, for instance:

```
resource "aws_s3_bucket" "s3-backup" {
  bucket = "${var.team}-${var.env}-${var.component}-mysql-s3-backup"
}

module "lambda_s3_backup" {
  source = "github.com/mergermarket/tf_lambda_s3_backup?ref=PLAT-71_initial_implementation"

  name                 = "${var.env}-${var.component}"
  # Could be "${aws_s3_bucket.s3-backup.id}", but using this to avoid the
  # count cannot be computer error
  bucket_name          = "${var.team}-${var.env}-${var.component}-mysql-s3-backup"
  bind_host_path       = "${var.data_volume_path}"
  bind_container_path  = "/mnt/data"
  cluster              = "atlassian"
  lambda_cron_schedule = "rate(3 hours)"

  backup_env = {
    "DATABASE_TYPE"     = "mysql"
    "DATABASE_HOSTNAME" = "${aws_db_instance.rds.address}"
    "DATABASE_PORT"     = "3306"
    "DATABASE_DB_NAME"  = "${aws_db_instance.rds.name}"
    "DATABASE_USERNAME" = "${aws_db_instance.rds.username}"
    "DATABASE_PASSWORD" = "${var.secrets["MYSQL_PASSWORD"]}"
    "RETENTION"         = 12
    "DUMPS_PATH"        = "/mnt/data/mysql"
    "S3_BUCKET_NAME"    = "${var.team}-${var.env}-${var.component}-mysql-s3-backup"
    "S3_BUCKET_PATH"    = "/backup/${var.component}/${var.env}"
    "SYNC_ORIGIN_PATH"  = "/mnt/data"
  }

  metadata = {
    component = "${var.component}"
    env       = "${var.env}"
  }
}
```


