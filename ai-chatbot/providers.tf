terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state for now. The state file holds the IAM access key secret, so it
  # is git-ignored (*.tfstate). Move to an encrypted S3 backend before sharing.
}

provider "aws" {
  region = var.region

  # Guard: refuse to run against any account other than the one chosen.
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project     = "medsarv"
      Component   = "ai-chatbot"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
