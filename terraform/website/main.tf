###########################
# SETUP
###########################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
  }

  backend "s3" {
    bucket = "terraform-state-200130288738"
    key    = "terraform-state-data-streaming-demo"
    region = "eu-central-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

###########################
# MODULES
###########################

module "vpc" {
  source = "./modules/networking"
  availability_zones = ["eu-central-1a", "eu-central-1b"]
}

module "api" {
  source = "./modules/api"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}

