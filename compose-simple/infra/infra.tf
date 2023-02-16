provider "aws" {
  region = var.region
}

# Internal variables

locals {
  common_tags = {
    "managed" = "automation",
    "ou"      = "devops",
    "purpose" = "ci",
    "env"     = var.env_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "public_subnets" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = cidrsubnet(var.cidr, 4, 15)
  networks = [
    { name = "pubaz1", new_bits = 4 }
    # { name = "pubaz2", new_bits = 4 },
    # { name = "pubaz3", new_bits = 4 },
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.env_name
  cidr = var.cidr

  azs                 = data.aws_availability_zones.available.names
  # private_subnets     = module.private_subnets.networks[*].cidr_block
  # private_subnet_tags = { Type = "private" }
  public_subnets      = module.public_subnets.networks[*].cidr_block
  public_subnet_tags  = { Type = "public" }

  enable_nat_gateway = false
  single_nat_gateway = false
  # Need DNS to address EFS by name
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.common_tags
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow ssh inbound traffic from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress-all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}