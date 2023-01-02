


resource "random_password" "master"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "kazim-wt-db-password"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result
}

# data "aws_secretsmanager_secret" "password" {
#   name = "kazim-wt-db-password"

# }

# data "aws_secretsmanager_secret_version" "password" {
#   secret_id = data.aws_secretsmanager_secret.password
# }

resource "aws_db_instance" "webapp" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  identifier_prefix    = "${var.prefix_db}"
  
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  username             = "dbadmin"
  password             = aws_secretsmanager_secret_version.password.secret_string

  db_subnet_group_name = "${aws_db_subnet_group.subnet_groups.name}"
  multi_az             =  true

}

resource "aws_db_subnet_group" "subnet_groups" {
  name       = "kazim-db-private"
  subnet_ids = "${var.private_subnet_groups}"

  tags = {
    Name = "Kazim"
  }
}