# Infrastructure CloudFormation Template

This CloudFormation template creates the necessary AWS infrastructure for a CI/CD pipeline using GitHub Actions with OIDC authentication.

## Resources Created

1. **S3 Bucket for Terraform State** - Stores Terraform state files with versioning and encryption
2. **S3 Bucket for Artifacts** - Stores build artifacts with lifecycle policies
3. **GitHub OIDC Provider** - Enables secure authentication from GitHub Actions
4. **IAM Role** - Allows GitHub Actions to assume role and perform deployments

## Features

- **Security**:
  - Server-side encryption enabled on all S3 buckets
  - Public access blocked on all buckets
  - OIDC-based authentication (no long-lived credentials)
  - Least privilege IAM permissions

- **Cost Optimization**:
  - Lifecycle policies to delete old versions and artifacts
  - Terraform state versions retained for 90 days
  - Artifacts retained for 30 days

- **Versioning**:
  - Both buckets have versioning enabled for rollback capability

## Prerequisites

1. An existing Elastic Beanstalk application and environment
2. GitHub repository configured for GitHub Actions
3. AWS CLI installed and configured

## Parameters

- `ProjectName`: Prefix for resource names (default: myproject)
- `GitHubOrg`: Your GitHub organization or username
- `GitHubRepo`: Your GitHub repository name
- `GitHubBranch`: Branch allowed to deploy (default: main)
- `CreateOIDCProvider`: Set to 'true' to create a new OIDC provider, 'false' to use existing one (default: false)
- `BeanstalkApplicationName`: Name of your Elastic Beanstalk application
- `BeanstalkEnvironmentName`: Name of your Elastic Beanstalk environment

**Note**: If you already have a GitHub OIDC provider in your AWS account, set `CreateOIDCProvider` to `false`. The template will automatically reference the existing provider at `arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com`.

## Deployment

### Option 1: Using AWS CLI

```bash
# Update parameters.json with your values
aws cloudformation create-stack \
  --stack-name my-infrastructure \
  --template-body file://infrastructure-template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

### Option 2: Using AWS Console

1. Open AWS CloudFormation Console
2. Click "Create stack" → "With new resources"
3. Upload the `infrastructure-template.yaml` file
4. Fill in the parameters
5. Check "I acknowledge that AWS CloudFormation might create IAM resources with custom names"
6. Click "Create stack"

## Verify Deployment

```bash
# Check stack status
aws cloudformation describe-stacks \
  --stack-name my-infrastructure \
  --query 'Stacks[0].StackStatus'

# Get outputs
aws cloudformation describe-stacks \
  --stack-name my-infrastructure \
  --query 'Stacks[0].Outputs'
```

## GitHub Actions Configuration

After deploying, configure your GitHub Actions workflow to use the OIDC role:

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/myproject-github-actions-role
          aws-region: us-east-1

      - name: Upload artifact to S3
        run: |
          aws s3 cp ./application.zip s3://myproject-artifacts-ACCOUNT_ID/

      - name: Create Beanstalk application version
        run: |
          aws elasticbeanstalk create-application-version \
            --application-name your-beanstalk-app \
            --version-label v${{ github.run_number }} \
            --source-bundle S3Bucket="myproject-artifacts-ACCOUNT_ID",S3Key="application.zip"

      - name: Deploy to Beanstalk
        run: |
          aws elasticbeanstalk update-environment \
            --environment-name your-beanstalk-env \
            --version-label v${{ github.run_number }}
```

## Terraform Backend Configuration

To use the Terraform state bucket, add this to your Terraform configuration:

```hcl
terraform {
  backend "s3" {
    bucket = "myproject-terraform-state-ACCOUNT_ID"
    key    = "path/to/my/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

## IAM Permissions Included

The OIDC role has permissions for:

- **S3**: Full access to both buckets (state and artifacts)
- **Elastic Beanstalk**: Create/update deployments and describe resources
- **Auto Scaling**: Read-only access for Beanstalk monitoring
- **EC2**: Read-only access for Beanstalk instance information
- **CloudWatch Logs**: Read logs for deployment monitoring

## Clean Up

To delete all resources:

```bash
# Empty S3 buckets first (versioned buckets must be emptied manually)
aws s3 rm s3://myproject-terraform-state-ACCOUNT_ID --recursive
aws s3api delete-objects \
  --bucket myproject-terraform-state-ACCOUNT_ID \
  --delete "$(aws s3api list-object-versions \
    --bucket myproject-terraform-state-ACCOUNT_ID \
    --output json \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

aws s3 rm s3://myproject-artifacts-ACCOUNT_ID --recursive
aws s3api delete-objects \
  --bucket myproject-artifacts-ACCOUNT_ID \
  --delete "$(aws s3api list-object-versions \
    --bucket myproject-artifacts-ACCOUNT_ID \
    --output json \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

# Delete the stack
aws cloudformation delete-stack --stack-name my-infrastructure
```

## Troubleshooting

### OIDC Authentication Fails

- Verify the GitHub repository, organization, and branch match exactly
- Check that `id-token: write` permission is set in your workflow
- Ensure you're using the correct role ARN from the stack outputs

### Beanstalk Deployment Fails

- Verify the Beanstalk application and environment names are correct
- Check that the environment is in a ready state before deploying
- Ensure the artifact exists in the S3 bucket before creating an application version

### S3 Access Denied

- Verify bucket names include your AWS account ID
- Check that the role has been properly assumed in GitHub Actions
- Ensure bucket names match exactly (they're case-sensitive)

## Security Considerations

1. **Limit Branch Access**: The template restricts OIDC access to a specific branch. Consider using environment-specific roles for production.
2. **Bucket Policies**: Consider adding additional bucket policies for cross-account access if needed.
3. **Encryption**: Currently using AES256. Consider KMS encryption for additional security.
4. **MFA**: Consider requiring MFA for sensitive operations via bucket policies.

## Next Steps

1. Customize lifecycle policies based on your retention requirements
2. Add CloudWatch alarms for deployment monitoring
3. Implement blue/green deployments in Elastic Beanstalk
4. Add SNS notifications for deployment events
5. Consider adding DynamoDB table for Terraform state locking
