// AWS provider configuration
region_name = "us-east-1"
endpoint_url = "http://localhost:4566"

// VPC and Subnet configuration
vpc_cidr_block = "10.20.0.0/16"
pub_sub_cidr_block_1 = "10.20.0.0/25"
pub_sub_cidr_block_2 = "10.20.0.128/25"
pub_sub1_az = "us-east-1a"
pub_sub2_az = "us-east-1b"

// EC2 instance configuration
ami_id = "ami-af46c959"  // replace with your desired AMI ID
instance_type = "t2.micro"
key_name = "my-key-pair"

// EBS configuration
ebs_availability_zone = "us-east-1a"
ebs_size = 10

// S3 bucket configuration
bucket_name = "nimbuskart-app-logs-bucket-26"