
locals {
  artifact_path = "${path.root}/../../lambda"
}

resource "aws_iam_role" "ingest" {
  name               = "streaming-demo-ingest-lambda-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.ingest.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.ingest.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "ingest" {
  name = "kafka-cluster-full-access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "kafka-cluster:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ingest" {
  role       = aws_iam_role.ingest.name
  policy_arn = aws_iam_policy.ingest.arn
}

resource "aws_cloudwatch_log_group" "ingest" {
  name = "/aws/lambda/${aws_lambda_function.ingest.function_name}"
  retention_in_days = 30
}

resource "aws_security_group" "ingest" {
  vpc_id = var.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lambda_function" "ingest" {
  filename         = local.jar_path
  function_name    = "streaming-demo-ingest-lambda"
  role             = aws_iam_role.ingest.arn
  handler          = "ingest.SimpleApiGatewayKafkaProxy::handleRequest"
  source_code_hash = filebase64sha256(local.jar_path)
  runtime          = "java11"
  memory_size      = 512
  timeout          = 120

  vpc_config {
    security_group_ids = [aws_security_group.ingest.id]
    subnet_ids         = var.subnet_ids
  }

  environment {
    variables = {
      "TOPIC_NAME": "ingest_json"
      "BOOTSTRAP_SERVERS": var.kafka_boostrap_servers
    }
  }
}

resource "aws_api_gateway_rest_api" "ingest" {
  name        = "StreamingDemoIngestAPI"
  description = ""
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "ingest" {
  rest_api_id = aws_api_gateway_rest_api.ingest.id
  parent_id   = aws_api_gateway_rest_api.ingest.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "ingest" {
  rest_api_id   = aws_api_gateway_rest_api.ingest.id
  resource_id   = aws_api_gateway_resource.ingest.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ingest" {
  rest_api_id             = aws_api_gateway_rest_api.ingest.id
  resource_id             = aws_api_gateway_resource.ingest.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ingest.invoke_arn
}

resource "aws_lambda_permission" "ingest" {
  statement_id  = "AllowAPIGatewayPOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ingest.execution_arn}/*/POST/*"
}

resource "aws_api_gateway_deployment" "ingest" {
  rest_api_id = aws_api_gateway_rest_api.ingest.id
  stage_name  = "dev"

  depends_on = [
    aws_api_gateway_integration.ingest
  ]

  lifecycle {
    create_before_destroy = true
  }
}

