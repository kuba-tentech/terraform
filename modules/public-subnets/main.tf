data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "public-subnet" {
  count                   = length(var.cidr_block)
  availability_zone       = count.index % 2 == [0] ? data.aws_availability_zones.azs.names[0] : data.aws_availability_zones.azs.names[1]
  cidr_block              = var.cidr_block[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = var.vpc_id

  tags = {
    Name = "public_${count.index + 1}"
  }
}
