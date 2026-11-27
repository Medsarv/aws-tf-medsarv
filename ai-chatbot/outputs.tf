output "region" {
  value = var.region
}

output "default_model_id" {
  value       = var.inference_profile_ids[0]
  description = "Set as BEDROCK_MODEL_ID in the EMR backend .env"
}

output "policy_arn" {
  value       = aws_iam_policy.bedrock_invoke.arn
  description = "Attach to the EC2/ECS role when the backend is deployed"
}

output "access_key_id" {
  value = try(aws_iam_access_key.chatbot[0].id, null)
}

output "secret_access_key" {
  value     = try(aws_iam_access_key.chatbot[0].secret, null)
  sensitive = true
}
