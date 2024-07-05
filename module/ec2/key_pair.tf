resource "aws_key_pair" "key_bax" {
  key_name   = var.key_name
  public_key = file("${path.module}/${var.key_name}.pub")
}