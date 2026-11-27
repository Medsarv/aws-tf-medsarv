# MedSarv AI chatbot — AWS resources

Terraform for the Bedrock-backed chart assistant (doctor + patient).

| Resource | Purpose | Idle cost |
|---|---|---|
| IAM policy `medsarv-ai-chatbot-<env>-invoke` | Invoke only the approved Bedrock models | $0 |
| IAM user `medsarv-ai-chatbot-<env>` + access key | Local-dev identity for the EMR backend | $0 |
| Budget (optional, needs `budget_alert_email`) | Spend alert on Amazon Bedrock | $0 |

Bedrock is pay-per-token — there is nothing running between requests. Default model is
**Amazon Nova Lite** via the `apac.` inference profile in `ap-south-1`.

## Apply

```bash
export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=...   # admin creds for the target account
terraform init
terraform plan  -out tfplan
terraform apply tfplan
```

## Wire into the EMR backend

```bash
terraform output default_model_id
terraform output access_key_id
terraform output -raw secret_access_key
```

Put them in `EMR/backend/.env` as `BEDROCK_REGION`, `BEDROCK_MODEL_ID`,
`BEDROCK_AWS_ACCESS_KEY_ID`, `BEDROCK_AWS_SECRET_ACCESS_KEY`.

## Notes
- `aws_account_id` is a guard: Terraform refuses to run against any other account.
- State is local and holds the access-key secret (git-ignored). Use an encrypted S3 backend before sharing.
- To deploy: attach `policy_arn` to the backend's EC2/ECS role and set `create_access_key = false`.
