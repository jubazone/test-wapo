aws_profile    = "aws_bax"
aws_region     = "us-east-1"
aws_repository = "ecr_repo"
environment    = "dev"

vpc_cidr             = "10.3.0.0/18"
private_subnet_cidrs = ["10.3.10.0/24"]
public_subnet_cidrs  = ["10.3.5.0/24", "10.3.7.0/24", "10.3.9.0/24"]

msk_instance_type = "t2.micro"
key_name = "key_bax"


msk_ami = "ami-06c68f701d8090592"
namedb  = "baxtest"
userdb  = "usrbax"
passdb  = "baxxx"