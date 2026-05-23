variable "vpc_cidr_block" {
  type = string
  description = "cidr block with series"
}

variable "pub_sub_cidr_block_1" {
  type = string
  description = "cidr block for public subnet 1"
}

variable "pub_sub_cidr_block_2" {
  type = string
  description = "cidr block for public subnet 2"
}

variable "pub_sub1_az" {
  type = string
  description = "availability zone for public subnet 1"
}

variable "pub_sub2_az" {
  type = string
  description = "availability zone for public subnet 2"
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
