# Pantry Cloud, fixed: the AWS infrastructure for a small app, with every lab
# fix applied (Cloud Defense, Nirvik Ready).
# It is safe to apply to a sandbox account; destroy it afterward.
# This is the fixed version: compare it with the files one folder up.

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

variable "admin_cidr" {
  description = "The one address range allowed to reach the server's SSH port, if any (for example your office). Prefer SSM Session Manager instead."
  type        = string
  default     = "203.0.113.10/32"
}

variable "github_repository" {
  description = "The only GitHub repository allowed to deploy, as owner/name."
  type        = string
  default     = "your-org/pantry"
}
