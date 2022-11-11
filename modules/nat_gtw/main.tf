resource "aws_nat_gateway" "hw1-natgtw" {
  allocation_id = aws_eip.natgtw_eip.id
  subnet_id     = var.subnet_id
  depends_on = [aws_eip.natgtw_eip]

  tags = {
    Name = "hw1_natgw"
  }
}

resource "aws_eip" "natgtw_eip" {
  vpc = true

  tags = {
    Name = "my_eip"
  }
}