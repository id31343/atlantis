data "aws_availability_zones" "available" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "latest_for_atlantis" {
  owners      = [var.atlantis_ami_owner]
  most_recent = true

  filter {
    name   = "name"
    values = [var.atlantis_ami_name_filter]
  }
}

resource "tls_private_key" "atlantis_host_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "atlantis_public_key" {
  key_name   = var.atlantis_key_name
  public_key = tls_private_key.atlantis_host_key_pair.public_key_openssh
}

resource "aws_secretsmanager_secret" "atlantis_private_key" {
  name        = var.atlantis_key_name
  description = var.atlantis_key_description
}

resource "aws_secretsmanager_secret_version" "atlantis_private_key" {
  secret_id     = aws_secretsmanager_secret.atlantis_private_key.id
  secret_string = tls_private_key.atlantis_host_key_pair.private_key_pem
}

resource "aws_security_group" "atlantis" {
  vpc_id      = data.aws_vpc.default.id
  name        = var.atlantis_sg_name
  description = var.atlantis_sg_description

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.atlantis_sg_ingress

    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_instance" "alpha" {
  ami           = data.aws_ami.latest_for_atlantis.id
  instance_type = var.atlantis_instance_type

  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_security_group_ids = [aws_security_group.atlantis.id]

  tags = {
    Name = "atlantis"
  }
}
