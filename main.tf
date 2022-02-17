provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "k3s-master-mysql" {
  ami = var.ami
  instance_type = var.type
  key_name = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  root_block_device {
    volume_size = 13
    volume_type = "gp3"
  }

  user_data = templatefile("mysql-serv.sh.tpl", {
    db_user = var.db_user
    db_pass = var.db_pass
    db_database = var.db_database
    })
  tags = {Name="k3s-master-mysql"}
}

resource "aws_instance" "k3s-worker" {
  depends_on = [aws_instance.k3s-master-mysql]
  ami = var.ami
  instance_type = var.type
  key_name = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  root_block_device {
    volume_size = 13
    volume_type = "gp3"
  }

  user_data = templatefile("rancher-instance.sh.tpl", {
    db_user = var.db_user
    db_pass = var.db_pass
    db_database = var.db_database
    db_hostname = aws_instance.k3s-master-mysql.public_ip
    })
  tags = {Name="k3s-worker"}

  provisioner "file" {
    source      = "./test-manifest.yaml"
    destination = "/home/ubuntu/test-manifest.yaml"
    connection {
      type     = "ssh"
      host     = self.public_ip
      user     = "ubuntu"
      private_key = file("my-first-instance.pem")
    }
  }
}
