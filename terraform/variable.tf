variable "region_name" {
  type        = string
  description = "region to create infra"
}

variable "endpoint_url" {
  type        = string
  description = "endpoint url for localstack"
}

variable "vpc_cidr_block" {
  type        = string
  description = "cidr block with series"
}

variable "pub_sub_cidr_block_1" {
  type        = string
  description = "cidr block for public subnet 1"
}

variable "pub_sub_cidr_block_2" {
  type        = string
  description = "cidr block for public subnet 2"
}

variable "pub_sub1_az" {
  type        = string
  description = "availability zone for public subnet 1"
}

variable "pub_sub2_az" {
  type        = string
  description = "availability zone for public subnet 2"
}

variable "ami_id" {
  type        = string
  description = "ami id for ec2 instance"
}

variable "instance_type" {
  type        = string
  description = "instance type for ec2 instance"
}

variable "key_name" {
  type        = string
  description = "key name for ec2 instance"
}

variable "ebs_availability_zone" {
  type        = string
  description = "availability zone for ebs volume"
}

variable "ebs_size" {
  type        = number
  description = "size of ebs volume in gigabytes"
}

variable "bucket_name" {
  type        = string
  description = "name of the s3 bucket"
}