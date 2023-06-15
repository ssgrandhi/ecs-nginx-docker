

#======================================================================================
#APIGATEWAY RESOURCE SECTION

resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
#cloud watch logs
resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/apigateway/${var.api_name}"
  #retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "api_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}


resource "aws_api_gateway_resource" "resource" {
  count       = length(var.path_part["path"])
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = count.index == 0 ? aws_api_gateway_rest_api.api.root_resource_id : aws_api_gateway_resource.resource[count.index - 1]
  path_part   = "X"
}

# resource "aws_api_gateway_resource" "resource2" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_resource.resource1.id
#   path_part   = var.path_part[1]
# }

# resource "aws_api_gateway_resource" "resource3" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_resource.resource2.id
#   path_part   = var.path_part[2]
# }

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource[length(var.path_part["path"]) - 1].id
  http_method   = var.path_part["http_method"]
  authorization = "NONE"
  # authorization = "COGNITO_USER_POOLS"
  # authorizer_id = aws_api_gateway_authorizer.rga_authorizer.id

}

# resource "aws_api_gateway_integration" "lambda-intergation" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.resource3.id
#   http_method             = aws_api_gateway_method.this.http_method
#   integration_http_method = var.http_method[1]
#   type                    = "AWS_PROXY"
#   #uri                     = aws_lambda_function.lambda_with_vpc.invoke_arn //direcly using uri
#   uri = module.lambda.lambda_function_invoke_arn //using module output value

# }

# resource "aws_lambda_permission" "lambda_permission" {
#   statement_id = "lambda-permission"
#   action       = "lambda:InvokeFunction"
#   #function_name = aws_lambda_function.lambda_with_vpc.function_name
#   function_name = module.lambda.lambda_function_name
#   principal     = "apigateway.amazonaws.com"
#   #source_arn = "${aws_api_gateway_rest_api.api_arn}/*/${aws_api_gateway_method.this.http_method}
#   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.resource3.path}"
# }

#cognito to apigateway authorization 

# resource "aws_api_gateway_authorizer" "rga_authorizer" {
#   name          = "rga-congnito-userpool-authorizer"
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   type          = "COGNITO_USER_POOLS"
#   provider_arns = toset([module.cognito.rga_user_pool_arn]) #aws_cognito_user_pool.rga_user_pool.arn

#   #authorization_scopes =  ["openid"]

#   identity_source = "method.request.header.Authorization"


# }

# resource "aws_api_gateway_deployment" "example_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   depends_on  = [aws_api_gateway_integration.lambda-intergation]
#   triggers = {
#     redeployment = sha1(jsonencode([
#       aws_api_gateway_resource.resource3.id,
#       aws_api_gateway_method.this.http_method,
#       aws_api_gateway_integration.lambda-intergation.id,
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   stage_name  = "test"
#   description = "test stage"

# }
