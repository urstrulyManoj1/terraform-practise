provider "aws" {
    region = "us-west-1"  
}

resource "aws_vpc" "vpc" {
  cidr_block = "12.0.0.0/16"
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "12.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnet_pub"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "12.0.2.0/24" # Choose a valid CIDR block within the VPC range
  availability_zone = "us-west-2b"
  tags = {
    Name = "subnet_pvt"
  }
}


resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]
  tags = {
    Name = "db_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route_table"
  }
}

resource "aws_route_table_association" "route_ass" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route.id
}

// ec2
resource "aws_instance" "ec2" {
  ami           = "ami-036cafe742923b3d9"
  key_name      = "vpc02-ec2-key"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-jenkins-ec2"
  }
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
}

//ec2 sg
resource "aws_security_group" "ec2_sg" {
  tags = {
    Name = "ec2_sg"
  }
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

//rds
resource "aws_db_instance" "rds" {
  db_subnet_group_name   = "db_subnet"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  # Security group for RDS instance
  engine         = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.micro"
  tags = {
    Name = "mydatabase"
  }
  username            = "admin"
  password            = "password"
  allocated_storage   = 20
  skip_final_snapshot = true
}

//rds sg
resource "aws_security_group" "rds_sg" {
  tags = {
    Name = "rds_sg"
  }
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]

  }

}

