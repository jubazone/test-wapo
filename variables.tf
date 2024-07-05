variable "aws_profile" {
  type = string
}

variable "aws_repository" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}


variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "private_subnet_cidrs" {
  type = list(any)
}

variable "public_subnet_cidrs" {
  type = list(any)
}

variable "namedb" {
  type = string
}

variable "userdb" {
  type = string
}

variable "passdb" {
  type      = string
  sensitive = true
}

variable "msk_instance_type" {
  type = string
}

variable "msk_ami" {
  type = string
}

variable "key_name" {
  type        = string
}



