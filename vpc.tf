#Create the vpc with default cidrblock 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidrblock

  tags = {
    Name = "reliable-main"
  }
}

#Define internet gateway in vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "reliable-igw"
  }
}

###############Start define subnets######################
# Define 3 private subnets to host ec2 vm
resource "aws_subnet" "private" {
  count = length(var.private-subnets)

  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.availability-zone, count.index)
  cidr_block        = element(var.private-subnets, count.index)

  tags = {
    Name = "main-private-subnet-${count.index}"
  }
}

# Define 3 public subnets to host nat gatewaay in each subnet
resource "aws_subnet" "public" {
  count = length(var.public-subnets)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.availability-zone, count.index)
  cidr_block              = element(var.public-subnets, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "main-public-subnet-${count.index}"
  }
}
###############End Create subnets######################


###############Start Create security group######################
#Create security group for application load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "allow traffic from internet"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.sg_rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  ingress {
    description = "allow port 5000 traffic"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-external"
  }
}

#Create security group for ec2 autoscaling group
resource "aws_security_group" "vm_sg" {

  depends_on = [
    aws_security_group.alb_sg
  ]

  name        = "vm-sg"
  description = "allow alb sg"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.sg_rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  ingress {
    description = "allow port 5000 traffic"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vm-sg-internal"
  }
}
###############End Create Security Group######################

###############start Create routes######################
#Create route for public subnet and attach to internet gateway
#the traffic from and to internet in nat gaway and application load balancer go through internet gateway
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Attach each public subnet to public route
resource "aws_route_table_association" "a" {
  count = length(var.public-subnets)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public-rt.id
}

# The outbound internet traffic from ec2 in each private subnet go through nat gateway
# Create route for private subnet and attach to nat gateway
resource "aws_route_table" "private-rt" {
  count = length(var.private-subnets)

  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat[*].id, count.index)
  }

  tags = {
    Name = "private-${count.index}-rt"
  }
}

resource "aws_route_table_association" "b" {
  count = length(var.private-subnets)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private-rt[*].id, count.index)
}

###############End Create Routes######################