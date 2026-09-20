output "environment_ips" {
  value       = { for env, eip in aws_eip.env : env => eip.public_ip }
  description = "Elastic IPs per environment - point your DNS A records here"
}

output "instance_ids" {
  value       = { for env, inst in aws_instance.env : env => inst.id }
  description = "EC2 instance IDs per environment - needed by admin-portal's deploy workflow"
}

output "ssh_commands" {
  value = {
    for env, eip in aws_eip.env : env => "ssh -i ~/.ssh/medrecord-pro-deploy-key ec2-user@${eip.public_ip}"
  }
}
