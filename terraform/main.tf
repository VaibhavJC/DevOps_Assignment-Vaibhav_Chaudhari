module "vpc" {
  source               = "./modules/network"
  vpc_cidr_block       = var.vpc_cidr_block
  pub_sub_cidr_block_1 = var.pub_sub_cidr_block_1
  pub_sub_cidr_block_2 = var.pub_sub_cidr_block_2
  pub_sub1_az          = var.pub_sub1_az
  pub_sub2_az          = var.pub_sub2_az
}
