# Nat gateway is for vm to update software
# and install web server from internet so that
# alb's http health check available

# Create 3 elastic ip
resource "aws_eip" "nat_eip" {
  count = length(var.public-subnets)

  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Create 3 nat gateway in each public subnet
resource "aws_nat_gateway" "nat" {
  count = length(var.public-subnets)

  allocation_id = element(aws_eip.nat_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
}