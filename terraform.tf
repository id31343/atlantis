terraform {
  required_version = "1.6.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "vadim.baranovsky-atlantis"
    key    = "terraform.tfstate"
    region = "eu-north-1"
    # role_arn = "arn:aws:iam::738460351922:role/Atlantis"
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  # Put in variables
  assume_role {
    role_arn     = "arn:aws:iam::738460351922:role/Atlantis"
    session_name = "atlantis"
  }

  default_tags {
    tags = var.default_tags
  }

  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
