variable "name" {
  description = "Name for this backup task"
}

variable "bucket_name" {
  description = "Bucket to sync the files to"
}

variable "lambda_cron_schedule" {
  description = "The scheduling expression for how often the lambda function runs."
  default     = "rate(3 hours)"
}

variable "bind_host_path" {
  description = "Host volume to mount into the container. Must be set together with bind_host_path"
  default     = "/tmp/dummy"
}

variable "bind_container_path" {
  description = "Container volume to mount into the container. Must be set together with bind_container_path"
  default     = "/tmp/dummy"
}

variable "cluster" {
  description = "Name of the ECS cluster where the ECS task would run"
  default     = "default"
}

variable "docker_image" {
  description = "Docker image to use for the task. It should contain all the logic to perform the dump and sync"
  default     = "mergermarket/docker-mysql-s3-backup"
}

variable "docker_command" {
  description = "Custom command to run in the container"
  default     = ""
}

variable "backup_env" {
  description = "Environment parameters passed to the lambda function and the container"
  type        = map(string)
  default     = {}
}

variable "metadata" {
  description = "Metadata for the resources created by this module"
  type        = map(string)
  default     = {}
}

