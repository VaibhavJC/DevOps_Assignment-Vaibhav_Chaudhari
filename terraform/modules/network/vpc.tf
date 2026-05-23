resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    instance_tenancy = "default"

    tags = {
        Name = "my_vpc"
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "my_igw"
    }

    depends_on = [aws_vpc.my_vpc]
}

resource "aws_subnet" "pub_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.pub_sub_cidr_block_1
    availability_zone = var.pub_sub1_az
    map_public_ip_on_launch = true

    tags = {
        Name = "pub_subnet_1"
    }

    depends_on = [aws_vpc.my_vpc]
}

resource "aws_subnet" "pub_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.pub_sub_cidr_block_2
    availability_zone = var.pub_sub2_az
    map_public_ip_on_launch = true

    tags = {
        Name = "pub_subnet_2"
    }

    depends_on = [aws_vpc.my_vpc]
}

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

     tags = {
        Name = "pub_rt"
    }

    depends_on = [aws_vpc.my_vpc, aws_internet_gateway.my_igw]
}

resource "aws_route_table_association" "pub_rt_assoc_1" {
    subnet_id = aws_subnet.pub_subnet_1.id
    route_table_id = aws_route_table.pub_rt.id

    depends_on = [aws_route_table.pub_rt, aws_subnet.pub_subnet_1, aws_internet_gateway.my_igw]
}

resource "aws_route_table_association" "pub_rt_assoc_2" {
    subnet_id = aws_subnet.pub_subnet_2.id
    route_table_id = aws_route_table.pub_rt.id

    depends_on = [aws_route_table.pub_rt, aws_subnet.pub_subnet_2, aws_internet_gateway.my_igw]
}

resource "aws_security_group" "allow_ssh_http" {
    name = "allow_ssh_http"
    description = "Allow SSH and HTTP inbound traffic"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_ssh_http"
    }

    depends_on = [aws_vpc.my_vpc]
}

