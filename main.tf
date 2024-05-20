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
  password             = "Admin@123"  # Use a strong password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  # Set this to your actual VPC security group IDs
  vpc_security_group_ids = ["sg-09fe7f3c0f9aacc32"]

  # Set this to your actual DB subnet group name
  db_subnet_group_name = "default"

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

