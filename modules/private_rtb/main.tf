resource "aws_route_table" "private-rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.natgtw_id
  }

  tags = {
    Name = "private-rtb"
  }
}