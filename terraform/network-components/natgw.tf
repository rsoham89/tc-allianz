resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name  = "public_1_nat"
    stage = "dev"
    owner = "Soham"
  }

}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name  = "public_2_nat"
    stage = "dev"
    owner = "Soham"
  }
}
