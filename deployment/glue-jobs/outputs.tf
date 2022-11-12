output "arn" {
  description = "This is the permissions for aws glue jobs"
  value = var.glue_job_role_arn
  sensitive = true
}

output "aws_glue_job" {
  value = aws_glue_job.glue_job_resource[*]
}

output "glue_scripts" {
    value = var.glue_scripts[*]
}

output "aws_scripts_location" {
  value = var.aws_scripts_location
}

output "glue_max_concurrent_runs" {
  description = ""
  value = var.glue_max_concurrent_runs
}

output "glue_job_default_arguments" {
  value = var.glue_job_default_arguments
}

output "glue_job_execution_property" {
  description = "(Optional) Execution property of the job."
  value = var.glue_job_execution_property
}

output "job-language" {
    value = var.job-language
}

output "glue_version" {
  value = var.glue_version
}

output "glue_maximum_capacity" {
  description = ""
  value = var.glue_maximum_capacity
}

output "glue_maximum_retries" {
  descrition = "Number of retries for AWS Glue jobs"
  value = var.glue_maximum_retries
}

output "glue_job_connections" {
  value = var.glue_job_connections
}

output "glue_timeout" {
  description = "Timeout set for glue jobs."
  value = var.glue_timeout
}

output "glue_non_overridable_arguments" {
    description = ""
    value = var.glue_non_overridable_arguments
}

output "glue_tags" {
  description = ""
  value = var.glue_tags
}

output "glue_tags_all" {
  description = ""
  value = var.glue_tags_all
}

output "glue_job_type" {
  value = var.glue_job_type
}

output "glue_python_version" {
  description = ""
  value = var.glue_python_version
}

output "aws_bucket_name" {
  description = "Location where the glue jobs will be stored."
  value = var.aws_bucket_name
}