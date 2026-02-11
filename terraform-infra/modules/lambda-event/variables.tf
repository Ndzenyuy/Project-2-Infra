variable "lambda_role_name" {
    description = "Name of the IAM role for Lambda execution"
    type        = string
    default     = "lumiatech-lambda-execution-role"  
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}
variable "lambda_sg_id" {
  description = "Lambda security group ID"
  type        = string
}