provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "one" {
 count                  = 1
 ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  tags = {
    Name = "Prod"
    ENV = "Prod"
  }
}









