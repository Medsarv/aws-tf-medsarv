output "environment_ips" {
  value       = { for env, eip in aws_eip.env : env => eip.public_ip }
  description = "Elastic IPs per environment - point your DNS A records here"
}

output "rds_endpoints" {
  value       = { for env, db in aws_db_instance.env : env => db.endpoint }
  description = "RDS endpoints per environment"
}

output "instance_ids" {
  value       = { for env, inst in aws_instance.env : env => inst.id }
  description = "EC2 instance IDs per environment - needed by EMR/.github/workflows/deploy.yml"
}

output "ssh_commands" {
  value = {
    for env, eip in aws_eip.env : env => "ssh -i ~/.ssh/${var.project_name}-deploy-key ec2-user@${eip.public_ip}"
  }
}

output "db_password_secret_names" {
  value       = { for env, s in aws_secretsmanager_secret.db_password : env => s.name }
  description = "Secrets Manager entries holding each environment's RDS master password"
}
