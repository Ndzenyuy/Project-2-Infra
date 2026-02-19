variable "lambda_role_name" {
    description = "Name of the IAM role for Lambda execution"
    type        = string
    default     = "lumiatech-lambda-execution-role"  
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
# variable "private_subnets" {
#   description = "Private subnets"
#   type        = list(string)
# }
variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
}
variable "lambda_sg_id" {
  description = "Lambda security group ID"
  type        = string
}
variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
}
variable "db_name" {
  description = "Database name"
  type        = string
}
variable "db_username" {
  description = "Database username"
  type        = string
}
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
