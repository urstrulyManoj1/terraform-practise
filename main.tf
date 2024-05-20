provider "aws" {
  region     = "us-west-2"
}

resource "aws_instance" "web2" {
  ami           = "ami-023e152801ee4846a"
  instance_type = "t2.micro"
  tags = {
    Name = "ec2-jenkins-tf"
  }
}
