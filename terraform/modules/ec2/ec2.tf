resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIbSYbBMRla7xub6GjpZ1sHkvRXM9uwWzzX+/mtASLUU vaibhav@LAPTOP-NOQ3MIEE"
}

resource "aws_instance" "ec2_instance-1" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  subnet_id = var.public_subnet_1_id
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name = "web-tier"
  }
}

resource "aws_instance" "ec2_instance-2" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.key_pair.key_name
    subnet_id = var.public_subnet_2_id
    vpc_security_group_ids = [var.security_group_id]

    tags = {
      Name = "web-tier"
    }
}

resource "aws_instance" "ec2_instance-3" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.key_pair.key_name
    subnet_id = var.public_subnet_1_id
    vpc_security_group_ids = [var.security_group_id]

    instance_state = "stopped"

    tags = {
      Name = "web-tier"
    }
}
