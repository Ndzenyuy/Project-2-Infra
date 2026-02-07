# Terraform Elastic Beanstalk with RDS Infrastructure

This Terraform configuration creates a complete infrastructure for deploying a Tomcat 10 Corretto 17 Java application on AWS Elastic Beanstalk with an RDS MySQL database.

## Architecture Overview

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **Elastic Beanstalk**: Load-balanced environment with Auto Scaling Group
  - Min instances: 2
  - Max instances: 4
  - Instance type: t2.micro
  - Platform: Tomcat 10 with Corretto 17
- **RDS**: MySQL database instance
  - Storage: 20 GB (free tier eligible)
  - Instance: db.t3.micro (free tier eligible)
  - Security: Only accessible from Elastic Beanstalk instances

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (v1.0+)
3. An AWS account with appropriate permissions

## Project Structure

```
.
├── main.tf                          # Root module configuration
├── variables.tf                     # Root module variables
├── outputs.tf                       # Root module outputs
├── terraform.tfvars.example         # Example variables file
├── modules/
│   ├── vpc/
│   │   ├── main.tf                 # VPC resources
│   │   ├── variables.tf            # VPC variables
│   │   └── outputs.tf              # VPC outputs
│   ├── elastic-beanstalk/
│   │   ├── main.tf                 # Elastic Beanstalk resources
│   │   ├── variables.tf            # Elastic Beanstalk variables
│   │   └── outputs.tf              # Elastic Beanstalk outputs
│   └── rds/
│       ├── main.tf                 # RDS resources
│       ├── variables.tf            # RDS variables
│       └── outputs.tf              # RDS outputs
└── README.md                        # This file
```

## Quick Start

### 1. Clone or copy the configuration

Ensure all files are in place as shown in the project structure above.

### 2. Configure variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update the values:

```hcl
aws_region     = "us-east-1"
project_name   = "myapp"
environment    = "production"

# Update the database password!
db_password    = "YourSecurePassword123!"
```

**Important**: Never commit `terraform.tfvars` to version control if it contains sensitive information.

### 3. Initialize Terraform

```bash
terraform init
```

This downloads the required providers and initializes the modules.

### 4. Review the plan

```bash
terraform plan
```

Review the resources that will be created.

### 5. Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

## Deployment Timeline

The infrastructure typically takes 15-20 minutes to provision:
- VPC and networking: 2-3 minutes
- Elastic Beanstalk environment: 10-15 minutes
- RDS instance: 5-10 minutes

## Accessing Your Application

After deployment completes, Terraform will output the Elastic Beanstalk environment URL:

```bash
terraform output elastic_beanstalk_environment_url
```

Visit this URL in your browser to access your application (once you've deployed your application code).

## Deploying Your Application

To deploy your Java/Tomcat application to Elastic Beanstalk:

### Option 1: Using AWS CLI

```bash
# Package your application as a WAR file
# Then upload it to Elastic Beanstalk

aws elasticbeanstalk create-application-version \
  --application-name tomcat-app \
  --version-label v1.0 \
  --source-bundle S3Bucket="your-bucket",S3Key="your-app.war"

aws elasticbeanstalk update-environment \
  --environment-name tomcat-app-env \
  --version-label v1.0
```

### Option 2: Using AWS Console

1. Go to AWS Elastic Beanstalk console
2. Select your application
3. Click "Upload and deploy"
4. Upload your WAR file

### Option 3: Using EB CLI

```bash
eb init
eb deploy
```

## Connecting to RDS from Your Application

The RDS endpoint is available as a Terraform output:

```bash
terraform output rds_endpoint
```

In your application, use these environment variables (you'll need to add them to Elastic Beanstalk):

```
DB_HOST: <rds_endpoint_address>
DB_PORT: 3306
DB_NAME: myappdb
DB_USER: admin
DB_PASSWORD: <your_password>
```

To set environment variables in Elastic Beanstalk, you can either:

1. **Use AWS Console**: Elastic Beanstalk → Configuration → Software → Environment properties
2. **Use Terraform**: Add to the Elastic Beanstalk module:

```hcl
setting {
  namespace = "aws:elasticbeanstalk:application:environment"
  name      = "DB_HOST"
  value     = module.rds.db_address
}
```

## Customization

### Changing Instance Types

Edit `terraform.tfvars`:

```hcl
instance_type     = "t3.small"
db_instance_class = "db.t3.small"
```

### Adjusting Auto Scaling

Edit `terraform.tfvars`:

```hcl
min_size = 1
max_size = 6
```

### Changing Solution Stack

To use a different Tomcat or Java version, update the `solution_stack_name` in `terraform.tfvars`. 

To find available solution stacks:

```bash
aws elasticbeanstalk list-available-solution-stacks | grep Tomcat
```

## Monitoring and Maintenance

### Health Monitoring

Elastic Beanstalk provides enhanced health monitoring by default. Access it through:
- AWS Console: Elastic Beanstalk → Environment → Health
- AWS CLI: `aws elasticbeanstalk describe-environment-health`

### CloudWatch Logs

Logs are automatically sent to CloudWatch Logs. Access them at:
- AWS Console: CloudWatch → Logs → `/aws/elasticbeanstalk/`

### RDS Backups

Automated backups are enabled with:
- Retention period: 7 days
- Backup window: 03:00-04:00 UTC
- Maintenance window: Sunday 04:00-05:00 UTC

## Security Considerations

1. **Database Password**: Store securely and rotate regularly
2. **Security Groups**: 
   - RDS is only accessible from Elastic Beanstalk instances
   - Load balancer accepts traffic on ports 80 and 443
3. **VPC**: Instances run in private subnets with NAT gateway for outbound access
4. **IAM Roles**: Least privilege access for EC2 instances

## Cost Estimation

**Free Tier Eligible Resources:**
- EC2 t2.micro instances (750 hours/month)
- RDS db.t3.micro instance (750 hours/month)
- 20 GB RDS storage
- Data transfer (1 GB/month outbound)

**Potential Charges:**
- NAT Gateway: ~$33/month
- Application Load Balancer: ~$23/month
- Additional data transfer
- Resources beyond free tier limits

**Estimated Monthly Cost**: $56-80 (outside free tier)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted. This will remove all infrastructure components.

**Warning**: This will delete your database. Ensure you have backups if needed.

## Troubleshooting

### Issue: Elastic Beanstalk environment fails to launch

**Solution**: Check the events in the AWS Console under Elastic Beanstalk → Environments → Events

### Issue: Cannot connect to RDS

**Solution**: 
1. Verify security groups allow traffic from Elastic Beanstalk
2. Check that instances are in the correct subnets
3. Verify RDS endpoint and credentials

### Issue: Terraform state lock error

**Solution**: If using remote state with locking, ensure no other Terraform processes are running

## Best Practices

1. **Use Remote State**: Configure S3 backend for state storage
2. **Enable State Locking**: Use DynamoDB for state locking
3. **Separate Environments**: Use workspaces or separate state files for dev/staging/prod
4. **Version Control**: Commit all `.tf` files but exclude `terraform.tfvars` and `.tfstate`
5. **Automated Deployments**: Integrate with CI/CD pipelines

## Support

For issues related to:
- **Terraform**: Check [Terraform documentation](https://www.terraform.io/docs)
- **AWS Elastic Beanstalk**: Check [AWS documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- **This configuration**: Create an issue in your repository

## License

This configuration is provided as-is for educational and commercial use.

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Elastic Beanstalk Developer Guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/)
- [AWS RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/)
- [Tomcat Documentation](https://tomcat.apache.org/tomcat-10.0-doc/)
