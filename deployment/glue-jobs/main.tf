# MAINTAINED by Augius Engineers

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.8.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "crawler_prefix" {
  description = ""
  type = string
  default = "auguis"
}

locals {
  hashes_scripts = merge([for folder in var.glue_scripts :{
    for script in folder.scripts :
    "${folder.name}${script}" => {
      script_path_location = "${script}.py"
      glue_script_name     = "${var.crawler_prefix}-${script}"
      trigger_type         = folder.trigger_type
      schedule             = folder.schedule
  }}]...)
}

resource "aws_glue_job" "glue_job_resource"{
    connections = var.glue_job_connections
    default_arguments = var.glue_job_default_arguments
    glue_version = var.glue_version
    max_capacity = var.glue_maximum_capacity
    max_retries = var.glue_maximum_retries
    non_overridable_arguments = var.glue_arguments
    role_arn =  var.glue_job_role_arn
    tags = var.glue_tags 
    tags_all =  var.glue_tags_all
    timeout = var.glue_timeout

    for_each = local.hashes_scripts
    name = each.value.glue_script_name
    description = "This is the spark jobs for the jobs ${each.value.glue_script_name}"

    command {
      name = var.glue_job_type
      python_version = var.glue_python_version
      script_location = "s3://${var.aws_bucket_name}/${var.aws_scripts_location}/${each.value.script_path_location}"
    }

    execution_property {
      max_concurrent_runs = var.glue_max_concurrent_runs
    }
}

resource "aws_glue_trigger" "glue_job_schedules" {
  for_each = local.hashes_scripts
  description = ""
  type = each.value.trigger_type
  schedule = each.value.schedule

  name = each.value.glue_script_name
  actions {
    job_name = each.value.glue_script_name
  }
}