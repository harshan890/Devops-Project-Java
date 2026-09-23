terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "asg" {
  source                 = "./modules/asg"
  aws_vpc                = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  alb_security_group_id  = module.alb.alb_security_group_id
  target_group_arn       = module.alb.target_group_arn
  instance_type          = "t3.micro"
  key_name               = "new-web-key"
}

module "cloudwatch" {
  source   = "./modules/monitoring"
  asg_name = module.asg.asg_name
  vpc_id   = module.vpc.vpc_id
}

module "rds" {
  source                 = "./modules/rds"
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  app_security_group_id  = module.asg.app_security_group_id
  db_username            = "admin"
  db_password            = var.db_password
}