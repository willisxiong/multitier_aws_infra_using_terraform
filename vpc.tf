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
#Define 3 private subnets to host ec2 vm
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability-zone[0]
  cidr_block        = var.private-subnet1

  tags = {
    Name = "main-subnet-private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability-zone[1]
  cidr_block        = var.private-subnet2

  tags = {
    Name = "main-subnet-private2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability-zone[2]
  cidr_block        = var.private-subnet3

  tags = {
    Name = "main-subnet-private3"
  }
}

#define 3 public subnets to host nat gatewaay in each subnet
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability-zone[0]
  cidr_block              = var.public-subnet1
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet-public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability-zone[1]
  cidr_block              = var.public-subnet2
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet-public2"
  }
}

resource "aws_subnet" "public3" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability-zone[2]
  cidr_block              = var.public-subnet3
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet-public3"
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
  /*
  ingress {
    description = "allow TCP80 traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
*/
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

  /*
  ingress {
    description = "allow alb traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  #allow ssh traffic for troubleshooting
  ingress {
    description = "allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
*/
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

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public-rt.id
}

#the outbound internet traffic from ec2 in each private subnet go through nat gateway
#Create route for private subnet and attach to nat gateway1
resource "aws_route_table" "private1-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "private1-rt"
  }
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1-rt.id
}

#Create route for private subnet and attach to nat gateway2
resource "aws_route_table" "private2-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "private2-rt"
  }
}

resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2-rt.id
}

#Create route for private subnet and attach to nat gateway3
resource "aws_route_table" "private3-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat3.id
  }

  tags = {
    Name = "private3-rt"
  }
}

resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private3-rt.id
}
###############End Create Routes######################