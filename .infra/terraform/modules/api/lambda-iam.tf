
resource "aws_iam_role" "this" {
  name               = "${local.resource-prefix}-lambda-roles"
  assume_role_policy = data.aws_iam_policy_document.this_lambda.json
}

data "aws_iam_policy_document" "this_lambda" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this_network_interface" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


#####################
# Cloud Watch Config 
#####################

resource "aws_iam_role_policy_attachment" "this_basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#####################
# S3 access
#####################
data "aws_iam_policy_document" "s3_access" {
  statement {
    sid = "S3FullAccess"

    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "${local.resource-prefix}-s3-access"
  policy = data.aws_iam_policy_document.s3_access.json
}
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_access.arn
}


################
# lambda insight
################
resource "aws_iam_role_policy_attachment" "cloudwatch_lambda_insights" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

################
# Invoke other lambdas
################
data "aws_iam_policy_document" "invoke_lambdas" {
  statement {
    sid = "InvokeLambdas"
    actions = [
      "lambda:InvokeFunction",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "invoke_lambdas" {
  name   = "${local.resource-prefix}-invoke-lambdas"
  policy = data.aws_iam_policy_document.invoke_lambdas.json
}

resource "aws_iam_role_policy_attachment" "invoke_lambdas" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.invoke_lambdas.arn
}



