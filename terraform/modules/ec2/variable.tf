variable "ami_id" {
  description = "The ID of the AMI to use for the instance."
  type        = string
}

variable "instance_type" {
  description = "The type of instance to create."
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instance."
  type        = string
}

variable "public_subnet_1_id" {
  description = "The ID of the first public subnet to launch the instance in."
  type        = string
}

variable "public_subnet_2_id" {
  description = "The ID of the second public subnet to launch the instance in."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the instance in."
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance."
  type        = string
}
