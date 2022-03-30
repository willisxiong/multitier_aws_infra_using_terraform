# Nat gateway is for vm to update software
# and install web server from internet so that
# alb's http health check available

# Eip1 will attach to nat1 in public subnet1
resource "aws_eip" "nat_eip1" {
  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Eip2 will attach to nat2 in public subnet2
resource "aws_eip" "nat_eip2" {
  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Eip3 will attach to nat3 in public subnet3
resource "aws_eip" "nat_eip3" {
  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Create nat in public subnet1
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public1.id
}

# Create nat in public subnet2
resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public2.id
}

# Create nat in public subnet3
resource "aws_nat_gateway" "nat3" {
  allocation_id = aws_eip.nat_eip3.id
  subnet_id     = aws_subnet.public3.id
}
