variable "application_name" {
  description = "Elastic Beanstalk application name"
  type        = string
}

variable "environment_name" {
  description = "Elastic Beanstalk environment name"
  type        = string
}



variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for load balancer"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs for instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
