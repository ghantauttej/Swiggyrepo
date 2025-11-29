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
  db_subnet_group_name        = aws_db_subnet_group.swiggy-db-sub-grp.name
  vpc_security_group_ids      = ["${aws_security_group.swiggy-db-sg.id}"]
  multi_az                    = true
  skip_final_snapshot         = true
  publicly_accessible          = false

  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}











