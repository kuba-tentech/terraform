resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"

  tags = {
    "Name" = "handson_vpc"
  }
}

