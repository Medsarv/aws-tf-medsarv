data "aws_caller_identity" "current" {}

locals {
  name = "medsarv-ai-chatbot-${var.environment}"

  # Inference-profile ARNs live in the caller's account/region; the underlying
  # foundation-model ARNs are account-less and may sit in any region the profile routes to.
  profile_arns = [
    for id in var.inference_profile_ids :
    "arn:aws:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:inference-profile/${id}"
  ]

  # "apac.amazon.nova-lite-v1:0" -> "amazon.nova-lite-v1:0"
  foundation_model_arns = [
    for id in var.inference_profile_ids :
    "arn:aws:bedrock:*::foundation-model/${replace(id, "/^(apac|global|us|eu|in)\\./", "")}"
  ]
}

# ---------------------------------------------------------------------------
# Least-privilege policy: invoke only the listed models. Nothing else.
# Converse / ConverseStream are authorised by the InvokeModel actions.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "bedrock_invoke" {
  statement {
    sid    = "InvokeApprovedModelsOnly"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    resources = concat(local.profile_arns, local.foundation_model_arns)
  }
}

resource "aws_iam_policy" "bedrock_invoke" {
  name        = "${local.name}-invoke"
  description = "MedSarv AI chatbot: invoke approved Bedrock models only"
  policy      = data.aws_iam_policy_document.bedrock_invoke.json
}

# ---------------------------------------------------------------------------
# Dedicated identity for local development. In AWS (EC2/ECS) attach the policy
# above to the instance/task role instead and set create_access_key = false.
# ---------------------------------------------------------------------------
resource "aws_iam_user" "chatbot" {
  name = local.name
}

resource "aws_iam_user_policy_attachment" "chatbot" {
  user       = aws_iam_user.chatbot.name
  policy_arn = aws_iam_policy.bedrock_invoke.arn
}

resource "aws_iam_access_key" "chatbot" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.chatbot.name
}

# ---------------------------------------------------------------------------
# Optional spend alert (free for the first two budgets per account).
# ---------------------------------------------------------------------------
resource "aws_budgets_budget" "bedrock" {
  count = var.budget_alert_email == "" ? 0 : 1

  name         = "${local.name}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Bedrock"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_alert_email]
  }
}
