
resource "aws_iam_role" "lambda_execution" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "lambda_rds_policy" {
  name = "LambdaRDSPolicy"
  role = aws_iam_role.lambda_execution.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["rds:DescribeDBInstances", "rds:DescribeDBSubnetGroups", "rds:DescribeDBSecurityGroups"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
          Effect   = "Allow"
          Action   = ["ssm:GetParameter", "ssm:GetParameters"]
          Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/lumiatech/rds/*"
      },
      {
          Effect   = "Allow"
          Action   = ["kms:Decrypt"]
          Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_layer_version" "pymysql_layer" {
  layer_name          = "pymysql-layer"
  compatible_runtimes = ["python3.11"]
  filename            = "${path.module}/layers/pymysql_layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/layers/pymysql_layer.zip")
}

resource "aws_lambda_function" "initrds_lambda" {
  function_name = "lumiatech-init-rds-lambda"
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_execution.arn
  layers        = [aws_lambda_layer_version.pymysql_layer.arn]

  filename         = "${path.module}/init_rds.zip"
  source_code_hash = filebase64sha256("${path.module}/init_rds.zip")
  environment {
    variables = {
      DB_HOST  = var.rds_endpoint
      DB_NAME  = var.db_name
      DB_PORT  = "3306"
      USERNAME = var.db_username
      PASSWORD = var.db_password
    }
  }

  vpc_config {
    subnet_ids         = var.public_subnets
    # subnet_ids         = var.private_subnets
    security_group_ids = [var.lambda_sg_id]
  }
  timeout = 600
}





