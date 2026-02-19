# Quick Deployment Guide

## Step-by-Step Deployment Instructions

### Step 1: Prepare Your Environment

```bash
# Ensure AWS CLI is configured
aws configure

# Verify your credentials
aws sts get-caller-identity
```

### Step 2: Set Up Terraform Variables

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set a secure database password:
   ```hcl
   db_password = "YourSecurePassword123!"
   ```

### Step 3: Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create the infrastructure
terraform apply
```

When prompted, type `yes` to confirm.

### Step 4: Wait for Deployment

The deployment takes approximately 15-20 minutes. You'll see progress in the terminal.

### Step 5: Get Your Environment URL

After deployment completes:

```bash
terraform output elastic_beanstalk_environment_url
```

Copy this URL - this is where your application will be accessible.

### Step 6: Deploy Your Application

You have several options:

#### Option A: AWS Console
1. Go to AWS Console → Elastic Beanstalk
2. Select your application: `tomcat-app`
3. Click "Upload and deploy"
4. Upload your WAR file
5. Click "Deploy"

#### Option B: AWS CLI
```bash
# Upload your WAR to S3 first
aws s3 cp myapp.war s3://my-bucket/myapp.war

# Create application version
aws elasticbeanstalk create-application-version \
  --application-name tomcat-app \
  --version-label v1.0 \
  --source-bundle S3Bucket="my-bucket",S3Key="myapp.war"

# Deploy to environment
aws elasticbeanstalk update-environment \
  --environment-name tomcat-app-env \
  --version-label v1.0
```

### Step 7: Configure Database Connection

Get your RDS endpoint:
```bash
terraform output rds_endpoint
```

Add environment variables to Elastic Beanstalk:

1. Go to AWS Console → Elastic Beanstalk → Configuration
2. Click "Edit" on "Software"
3. Scroll to "Environment properties"
4. Add the following:
   - `DB_HOST`: (value from rds_endpoint, without :3306)
   - `DB_PORT`: 3306
   - `DB_NAME`: myappdb
   - `DB_USER`: admin
   - `DB_PASSWORD`: (your password from terraform.tfvars)
5. Click "Apply"

### Step 8: Verify Your Application

1. Visit your Elastic Beanstalk URL
2. Check that your application is running
3. Verify database connectivity

## Example JDBC Connection String

In your Java application, use:

```java
String url = "jdbc:mysql://" + System.getenv("DB_HOST") + ":" + 
             System.getenv("DB_PORT") + "/" + System.getenv("DB_NAME");
String username = System.getenv("DB_USER");
String password = System.getenv("DB_PASSWORD");

Connection conn = DriverManager.getConnection(url, username, password);
```

## Common Issues and Solutions

### Issue 1: Application won't deploy
- Check that your WAR file is valid
- Verify the solution stack version supports your Java version
- Check Elastic Beanstalk logs in the console

### Issue 2: Can't connect to database
- Verify environment variables are set correctly
- Check security groups allow traffic (they should by default)
- Ensure RDS instance is in "available" state

### Issue 3: High costs
- The NAT Gateway costs ~$33/month
- Consider using VPC endpoints or a cheaper NAT instance
- Stop non-production environments when not in use

## Cleanup

To remove all infrastructure:

```bash
terraform destroy
```

Type `yes` when prompted.

**⚠️ WARNING**: This will delete everything, including your database!

## What's Been Created

Your infrastructure includes:

✅ VPC with public and private subnets  
✅ Internet Gateway and NAT Gateway  
✅ Application Load Balancer  
✅ Auto Scaling Group (min: 2, max: 4 instances)  
✅ EC2 instances running Tomcat 10 with Corretto 17  
✅ RDS MySQL database (20 GB, free tier eligible)  
✅ Security groups configured correctly  
✅ IAM roles and instance profiles  
✅ CloudWatch monitoring enabled  

## Next Steps

1. Deploy your Java application
2. Set up CI/CD pipeline (optional)
3. Configure custom domain name (optional)
4. Enable HTTPS with SSL certificate (optional)
5. Set up application monitoring
6. Configure backup strategy

## Resources

- AWS Console: https://console.aws.amazon.com/
- Elastic Beanstalk: https://console.aws.amazon.com/elasticbeanstalk/
- RDS: https://console.aws.amazon.com/rds/
- CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/

## Support

If you encounter issues:
1. Check AWS CloudWatch logs
2. Review Elastic Beanstalk events
3. Verify security group rules
4. Check IAM permissions

Good luck with your deployment! 🚀
