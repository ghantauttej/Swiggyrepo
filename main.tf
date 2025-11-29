provider "aws" {
  region = "us-east-1"
}




# --- Lookup default VPC (so we can attach subnets to it) ---
data "aws_vpc" "default" {
  default = true
}

# --- Availability zones ---
data "aws_availability_zones" "az" {
  state = "available"
}

# --- Create 2 private subnets for RDS in different AZs ---
resource "aws_subnet" "rds_private" {
  count                   = 2
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, count.index) # /24 slices if default is /16
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "swiggy-rds-private-${count.index}"
    Role = "rds"
  }
}

# --- DB Subnet Group (RDS requires >= 2 AZs) ---
resource "aws_db_subnet_group" "swiggy_subnet" {
  name       = "swiggy-db-subnet-group"
  subnet_ids = aws_subnet.rds_private[*].id

  tags = {
    Name = "swiggy-db-subnet-group"
  }
}

# --- Security Group for RDS (allow MySQL from inside VPC) ---
resource "aws_security_group" "rds_sg" {
  name        = "swiggy-rds-sg"
  description = "Allow MySQL from VPC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]   # open only inside VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "swiggy-rds-sg"
  }
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












