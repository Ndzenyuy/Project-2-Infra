# Copy this file to terraform.tfvars and update values as needed

aws_region   = "us-east-1"
project_name = "lumiatech-beanstalk-v2"
# environment  = "dev"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# Elastic Beanstalk Configuration
application_name = "lumiatech-tomcat-app-v2"
environment_name = "lumiatech-tomcat-app-env-v2"
instance_type    = "t2.micro"
min_size         = 1
max_size         = 4

# RDS Configuration
db_name           = "Accounts"
db_username       = "admin"
db_password       = "admin123" # Change this!
allocated_storage = 20
db_instance_class = "db.t3.micro"
