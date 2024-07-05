resource "aws_secretsmanager_secret" "db_secret_bax" {
  name            = "db_secret_bax"
}

resource "aws_secretsmanager_secret_version" "db_secret_bax_version" {
  secret_id     = aws_secretsmanager_secret.db_secret_bax.id
  secret_string   = jsonencode({ "DB_USER"    = "${var.userdb}", "DB_PASSWORD" = "${var.passdb}"})
}