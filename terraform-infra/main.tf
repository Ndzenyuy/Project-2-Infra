terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module (if you don't have an existing VPC)
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_name         = var.project_name
  environment          = var.environment
}

# Elastic Beanstalk Module
module "elastic_beanstalk" {
  source           = "./modules/elastic-beanstalk"
  application_name = var.application_name
  environment_name = var.environment_name
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  project_name     = var.project_name
  environment      = var.environment
}

# RDS Module
module "rds" {
  source            = "./modules/rds"
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  allocated_storage = var.allocated_storage
  instance_class    = var.db_instance_class
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  beanstalk_sg_id   = module.elastic_beanstalk.security_group_id
  project_name      = var.project_name
  environment       = var.environment
}
