output "application_name" {
  description = "Elastic Beanstalk application name"
  value       = aws_elastic_beanstalk_application.app.name
}

output "environment_name" {
  description = "Elastic Beanstalk environment name"
  value       = aws_elastic_beanstalk_environment.env.name
}

output "environment_id" {
  description = "Elastic Beanstalk environment ID"
  value       = aws_elastic_beanstalk_environment.env.id
}

output "environment_url" {
  description = "Elastic Beanstalk environment URL"
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
}

output "security_group_id" {
  description = "Security group ID of Elastic Beanstalk instances"
  value       = aws_security_group.eb_instances.id
}

output "load_balancer_security_group_id" {
  description = "Security group ID of load balancer"
  value       = aws_security_group.eb_lb.id
}
