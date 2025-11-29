provider "aws" {
  region = "us-east-1"
}

#### RDS ####


resource "aws_db_instance" "swiggy-db" {
  allocated_storage           = 100
  storage_type                = "gp3"
  engine                      = "mysql"
  engine_version              = "8.0.43"
  instance_class              = "db.t4g.micro"
  identifier                  = "swiggy-db"
  username                    = "admin"
  password                    = "Devopsbyraham007*"
  parameter_group_name        = "default.mysql8.0"
  
  skip_final_snapshot         = true
  publicly_accessible          = false

  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}



# Get available AZs
data "aws_availability_zones" "az" {
  state = "available"
}

# Create 2 private subnets for RDS
resource "aws_subnet" "rds_private" {
  count                   = 2
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 4, count.index + 10)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false
}

# Subnet group required for RDS
resource "aws_db_subnet_group" "swiggy_subnet" {
  name       = "swiggy-db-subnet-group"
  subnet_ids = aws_subnet.rds_private[*].id

  tags = {
    Name = "swiggy-db-subnet-group"
  }
}











