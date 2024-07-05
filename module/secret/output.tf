output "secret_string" {
  value = aws_secretsmanager_secret_version.db_secret_bax_version.secret_string
}
