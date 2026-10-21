# Pantry Cloud: the AWS infrastructure for a small app, with deliberate
# security flaws, for the labs of Cloud Defense (Nirvik Ready).
# Scan it, fix it, rescan: you don't need an AWS account for that.
# Never apply this version to a real account. The fixed version is in solution/.

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  description = "A short, unique prefix for every resource name."
  type        = string
  default     = "pantry-lab"
}

data "aws_caller_identity" "current" {}
