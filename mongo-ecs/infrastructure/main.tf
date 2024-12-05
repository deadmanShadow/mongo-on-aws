terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }

  cloud {
    organization = ""

    workspaces {
      name = ""
    }
  }





}

provider "aws" {
  region = "us-east-1"
}


module "security" {
  source = "./security"
}


module "networking_module" {
  source = "./networking"
}

module "compute" {
  source        = "./compute"
  task_role_arn = module.security.task_execution_role_arn
  subnet_ids    = module.networking_module.subnet_ids
  efs_sg_id     = module.networking_module.efs_sg_id
  vpc_id        = module.networking_module.vpc_id
  mongo_sg_id   = module.networking_module.mongo_sg_id
  test_ec2_sg_id = module.networking_module.test_ec2_sg_id
  one_pub_subnet_id= module.networking_module.one_pub_subnet_id
  mongo_ssm_param_name = module.security.mongo_password_ssm_parameter
  mongo_username = "mongoadmin"
}
