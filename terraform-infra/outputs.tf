output "elastic_beanstalk_environment_url" {
  description = "Elastic Beanstalk environment URL"
  value       = module.elastic_beanstalk.environment_url
}

output "elastic_beanstalk_environment_name" {
  description = "Elastic Beanstalk environment name"
  value       = module.elastic_beanstalk.environment_name
}

output "elastic_beanstalk_security_group_id" {
  description = "Security group ID of Elastic Beanstalk instances"
  value       = module.elastic_beanstalk.security_group_id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
