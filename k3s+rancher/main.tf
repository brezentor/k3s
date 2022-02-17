provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "mysql-serv" {
  ami = var.ami
  instance_type = var.type
  key_name = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = templatefile("mysql-serv.sh.tpl", {
    db_user = var.db_user
    db_pass = var.db_pass
    db_database = var.db_database
    })
  tags = {Name="mysql-serv"}
}
resource "aws_instance" "rancher-instance" {
  depends_on = [aws_instance.mysql-serv]
  ami = var.ami
  instance_type = var.type
  key_name = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = templatefile("rancher-instance.sh.tpl", {
    db_user = var.db_user
    db_pass = var.db_pass
    db_database = var.db_database
    db_hostname = aws_instance.mysql-serv.public_ip
    })
  tags = {Name="rancher"}
}
