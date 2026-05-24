module "vpc" {
  source               = "./modules/network"
  vpc_cidr_block       = var.vpc_cidr_block
  pub_sub_cidr_block_1 = var.pub_sub_cidr_block_1
  pub_sub_cidr_block_2 = var.pub_sub_cidr_block_2
  pub_sub1_az          = var.pub_sub1_az
  pub_sub2_az          = var.pub_sub2_az
  vpc_id               = module.vpc.vpc_id
  public_subnet_1_id   = module.vpc.public_subnet_1_id
  public_subnet_2_id   = module.vpc.public_subnet_2_id
  security_group_id    = module.vpc.security_group_id

}

module "ec2" {
  source             = "./modules/ec2"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
  security_group_id  = module.vpc.security_group_id
}



module "ebs" {
  source            = "./modules/ebs"
  ebs_availability_zone = var.ebs_availability_zone
  ebs_size              = var.ebs_size
}

module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}