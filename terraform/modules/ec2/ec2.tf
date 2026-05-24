resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIbSYbBMRla7xub6GjpZ1sHkvRXM9uwWzzX+/mtASLUU vaibhav@LAPTOP-NOQ3MIEE"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role_s3_logging"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2_role_s3_logging"
  }
}

resource "aws_iam_policy" "ec2_role_policy" {
  name = "ec2_role_policy_s3_logging"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_role_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile_s3_logging"
  role = aws_iam_role.ec2_role.name

}

resource "aws_instance" "ec2_instance-1" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  subnet_id = var.public_subnet_1_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

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
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

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
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

    instance_initiated_shutdown_behavior = "stop"

     tags = {
      Name = "web-tier"
    }
}
