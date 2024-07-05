resource "aws_iam_instance_profile" "dbClient_Profile" {
  name = "dbClient_profile"
  role = aws_iam_role.dbClient_Role.name
}

resource "aws_iam_role" "dbClient_Role" {
  name = "dbClient_Role"
  path = "/"


  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_instance" "dbClient-EC2-Instance" {
  ami                    = var.msk_ami
  instance_type          = var.msk_instance_type
  key_name               = aws_key_pair.key_bax.key_name
  vpc_security_group_ids = [var.ec2_dbSG.id]
  user_data = data.template_file.postgres.rendered
  subnet_id            = var.public_subnet[1].id
  iam_instance_profile = aws_iam_instance_profile.dbClient_Profile.name

  tags = {
    Name = "ec2-dbClient"
  }
}

data "template_file" "postgres" {
  template = file("${path.module}/install_postgres.sh")
  vars = {
    userdb      = var.userdb,
    namedb      = var.namedb,
    passdb      = var.passdb
  }
}