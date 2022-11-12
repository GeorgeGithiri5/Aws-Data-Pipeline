# This Terraform file defines the variables for the infrastucture

variable "glue_scripts" {
    description = "Define names of spark scripts."
    default = {
        kapsule_job = {name="kapsule_data", scripts = ["kapsule_job"], trigger_type = "ON_DEMAND", schedule=""}
    }
    type = map(any)
}

variable "glue_job_role_arn" {
  description = "This is a glue role which have permission to access glue resources"
  default = "arn:aws:iam::881401823878:role/AWSGlueServiceRoleDefault"
  type = string
}

variable "glue_job_execution_property" {
  description = "(Optional) Execution property of the job."
  default = []
  type = list(any)
}

variable "job-language" {
  default = "python"
  type = string
}

variable "glue_version" {
  description = "The version of glue used for this job."
  type = string
  default = "2.0"
}

variable "glue_maximum_capacity" {
  description = "This Defines the number of workers"
  default = 10
  type = number
}

variable "glue_maximum_retries" {
  description = "The number of retries for AWS Glue jobs."
  default = 1
  type = number
}

variable "glue_job_connections" {
  description = "List of connections Used for the job."
  default = []
  type = list(any)
}

variable "glue_timeout" {
  description = "The timeout set for aws glue jobs."
  default = 30
  type = number
}

variable "glue_arguments" {
  description = "These are glue arguments for that will assist in running the jobs"
  default = {}
  type = map(any)
}

variable "glue_tags" {
  description = ""
  default = {}
  type = map(any)
}

variable "glue_tags_all" {
  description = ""
  default = {}
  type = map(any)
}

variable "glue_job_type" {
  description = ""
  default = "glueetl"
  type = string
}

variable "glue_python_version" {
  description = ""
  default = "3"
  type = string
}

variable "aws_bucket_name" {
  description = "This bucket will store our glue jobs scripts"
  default = "glue-services-scripts"
  type = string
}

variable "glue_job_default_arguments" {
  type = map(any)
  default = {
    "--TempDir"                          = "s3://glue-services-scripts/logs/"
    "--class"                            = "GlueApp"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
    "--enable-job-insights"              = "true"
    "--enable-metrics"                   = "true"
    "--enable-spark-ui"                  = "true"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--job-insights-byo-rules"           = "s3://glue-services-scripts/logs/"
    "--job-language"                     = "python"
    "--spark-event-logs-path"            = "s3://glue-services-scripts/logs/"
    "--extra-py-files"                   = "s3://glue-services-scripts/src/libs.zip"
    "--additional-python-modules"        = "gspread==5.3.2"
  }
}

variable "aws_scripts_location" {
  description = "Script Location on AWS S3."
  default = "src"
  type = string
}

variable "glue_max_concurrent_runs" {
  description = ""
  default = 4
  type = number
}