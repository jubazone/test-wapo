resource "aws_iam_instance_profile" "webClient_Profile" {
  name = "webClient_profile"
  role = aws_iam_role.webClient_Role.name
}

resource "aws_iam_role" "webClient_Role" {
  name = "webClient_Role"
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

resource "aws_instance" "webClient-EC2-Instance" {
  ami                    = var.msk_ami
  instance_type          = var.msk_instance_type
  key_name               = aws_key_pair.key_bax.key_name
  vpc_security_group_ids = [var.ec2_webSG.id]
  user_data              = data.template_file.ngix.rendered
  subnet_id            = var.public_subnet[2].id
  iam_instance_profile   = aws_iam_instance_profile.webClient_Profile.name
  tags = {
      Name = "ec2-webClient"
    }
}

data "template_file" "ngix" {
  template = file("${path.module}/install_ngix.sh")
}