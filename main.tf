module "vpc" {
  source               = "./module/vpc"
  aws_region           = var.aws_region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "ec2" {
  source            = "./module/ec2"
  private_subnet   = module.vpc.private_subnet
  public_subnet   = module.vpc.public_subnet
  ec2_dbSG          = module.vpc.ec2_dbSG
  ec2_webSG         = module.vpc.ec2_webSG
  msk_ami           = var.msk_ami
  msk_instance_type = var.msk_instance_type
  namedb            = var.namedb
  userdb            = jsondecode(module.secret.secret_string)["DB_USER"]
  passdb            = jsondecode(module.secret.secret_string)["DB_PASSWORD"]
  key_name = var.key_name
  

}

module "secret" {
  source = "./module/secret"
  userdb = var.userdb
  passdb = var.passdb
}

module "ecs" {
  source            = "./module/ECS"
  ecs_SG            = module.vpc.ec2_webSG
  environment       = var.environment
  subnet            = module.vpc.public_subnet
  vpc_id            = module.vpc.vpc_id
  account_id        = data.aws_caller_identity.current.account_id
  aws_region        = var.aws_region
}