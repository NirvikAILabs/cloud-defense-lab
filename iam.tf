# A user for the app, with an access key, and full admin "to get it working".
resource "aws_iam_user" "app" {
  name = "${var.name}-app"
}

resource "aws_iam_access_key" "app" {
  user = aws_iam_user.app.name
}

resource "aws_iam_user_policy" "app_admin" {
  name = "admin"
  user = aws_iam_user.app.name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "*", Resource = "*" }]
  })
}

output "app_secret_key" {
  value     = aws_iam_access_key.app.secret
  sensitive = true
}
