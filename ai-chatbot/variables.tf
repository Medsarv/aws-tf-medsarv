variable "aws_account_id" {
  description = "AWS account this module may be applied to (safety guard)."
  type        = string
  default     = "881953411973"
}

variable "region" {
  description = "Region for Bedrock runtime calls. ap-south-1 (Mumbai) has the APAC inference profiles for Nova."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "inference_profile_ids" {
  description = <<-EOT
    Bedrock inference profiles the chatbot may invoke. Default is Amazon Nova Lite
    (cheapest model with solid clinical summarisation) plus Nova Micro as a fallback.
    Nova Pro is allowed for stronger safety/instruction following. Claude Haiku 4.5 ("in." India-only
    profile) can be added once the Anthropic first-use form is submitted in the Bedrock console.
  EOT
  type        = list(string)
  default = [
    "apac.amazon.nova-lite-v1:0",
    "apac.amazon.nova-micro-v1:0",
    # Stronger instruction-following (e.g. allergy rules) at a higher per-token price.
    "apac.amazon.nova-pro-v1:0",
  ]
}

variable "create_access_key" {
  description = "Create an access key for the chatbot IAM user (needed to run the EMR backend locally). Turn off once the backend runs on an EC2/ECS role with the policy attached."
  type        = bool
  default     = true
}

variable "monthly_budget_usd" {
  description = "Monthly Bedrock spend alert threshold (USD)."
  type        = number
  default     = 25
}

variable "budget_alert_email" {
  description = "Email for budget alerts. Leave empty to skip creating the budget."
  type        = string
  default     = ""
}
