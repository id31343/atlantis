variable "region" {
  description = "AWS region"
  nullable    = false
  type        = string
  default     = "eu-north-1"
}

variable "default_tags" {
  description = "AWS region"
  nullable    = false
  type        = map(string)
  default = {
    Owner     = "vadim.baranovsky",
    ManagedBy = "Terraform"
  }
}

# ================================== BACKEND S3 ================================== 

variable "backend_s3_name" {
  description = "AWS S3 name for Terraform backend"
  nullable    = false
  type        = string
  default     = "vadim.baranovsky-atlantis"
}

# ================================== ATLANTIS EC2 ================================== 

variable "atlantis_ami_owner" {
  description = "AWS Atlantis AMI owner"
  nullable    = false
  type        = string
  default     = "137112412989"
}

variable "atlantis_ami_name_filter" {
  description = "AWS Atlantis AMI name filter"
  nullable    = false
  type        = string
  default     = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
}

variable "atlantis_instance_type" {
  description = "AWS Atlantis instance type"
  nullable    = false
  type        = string
  default     = "t3.micro"
}

variable "atlantis_key_name" {
  description = "AWS Atlantis host key name"
  nullable    = false
  type        = string
  default     = "atlantis-key"
}

variable "atlantis_key_description" {
  description = "AWS Atlantis host key description"
  nullable    = false
  type        = string
  default     = "Private key for Atlantis host"
}

variable "atlantis_role_name" {
  description = "AWS Atlantis role name"
  nullable    = false
  type        = string
  default     = "Atlantis"
}

variable "atlantis_sg_name" {
  description = "AWS Atlantis security group name"
  nullable    = false
  type        = string
  default     = "atlantis-sg"
}

variable "atlantis_sg_description" {
  description = "AWS Atlantis security group description"
  nullable    = false
  type        = string
  default     = "Security group for Atlantis"
}

variable "atlantis_sg_ingress" {
  description = "AWS Atlantis security group ingress rules"
  nullable    = false
  type = list(
    object({
      port     = number,
      protocol = string
    })
  )
  default = [{
    port     = 80
    protocol = "tcp"
    }, {
    port     = 443
    protocol = "tcp"
    }, {
    port     = 22
    protocol = "tcp"
    }, {
    port     = -1
    protocol = "icmp"
  }]
}
