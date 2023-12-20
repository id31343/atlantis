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

data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "atlantis" {
  name = var.atlantis_role_name
  role = aws_iam_role.atlantis.name
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.atlantis.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "atlantis" {
  name               = var.atlantis_role_name
  description        = "This role is specific for Atlantis"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json

  tags = {
    Name = var.atlantis_role_name
  }
}

# Change name of the resource to Atlantis
resource "aws_instance" "alpha" {
  ami           = data.aws_ami.latest_for_atlantis.id
  instance_type = var.atlantis_instance_type

  availability_zone      = data.aws_availability_zones.available.names[0]
  vpc_security_group_ids = [aws_security_group.atlantis.id]

  iam_instance_profile = aws_iam_instance_profile.atlantis.name

  # user_data = file("user_data.sh")

  tags = {
    Name = "atlantis"
  }
}

module "tfstate_backend" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "1.1.1"

  s3_bucket_name = var.backend_s3_name

  # mfa_delete = true

  dynamodb_enabled = false
}
