provider "aws" {
  region     = "us-west-1"
}

resource "aws_db_instance" "main" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Admin123"  # Use a strong password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  # Set this to your actual VPC security group IDs
  vpc_security_group_ids = ["sg-01c676b68a3a80b20","sg-00763455b312ff101"]

  # Set this to your actual DB subnet group name
  db_subnet_group_name = aws_db_subnet_group.custom.name

  # Backup settings
  backup_retention_period = 7
  backup_window           = "03:00-06:00"

  # Maintenance settings
  maintenance_window = "Mon:00:00-Mon:03:00"

  # Tags
  tags = {
    Name = "MyRDSInstance"
  }
}

resource "aws_db_subnet_group" "custom" {
  name       = "custom-db-subnet-group"
  subnet_ids = ["subnet-075652031249df1f9","subnet-082e9a7232cbcce9b","subnet-0dd7d7963c8233253"]  # Replace with your actual subnet IDs

  tags = {
    Name = "CustomDBSubnetGroup"
  }
}
