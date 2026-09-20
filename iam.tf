# These users already exist in the medsarv account — `terraform import` each one
# (see Readme) rather than applying, so Terraform doesn't try to recreate them.

resource "aws_iam_user" "ashish_ms" {
  name = "Ashish-MS"
}

resource "aws_iam_user_policy_attachment" "ashish_ms_admin" {
  user       = aws_iam_user.ashish_ms.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "sowmya_ms" {
  name = "Sowmya-MS"
}

resource "aws_iam_user_policy_attachment" "sowmya_ms_admin" {
  user       = aws_iam_user.sowmya_ms.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "medrecord_github_actions" {
  name = "medrecord-github-actions"
}

resource "aws_iam_user_policy" "medrecord_github_actions_deploy" {
  name = "medrecord-deploy-policy"
  user = aws_iam_user.medrecord_github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = "arn:aws:s3:::medrecord-pro-deploy-artifacts/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
        ]
        Resource = "*"
      },
    ]
  })
}
