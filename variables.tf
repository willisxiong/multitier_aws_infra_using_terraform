variable "aws-region" {
  type    = string
  default = "ap-east-1"
}

variable "vpc-cidrblock" {
  type    = string
  default = "10.10.0.0/16"
}

variable "availability-zone" {
  type    = list(string)
  default = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
}

variable "private-subnet1" {
  type    = string
  default = "10.10.1.0/24"
}

variable "private-subnet2" {
  type    = string
  default = "10.10.2.0/24"
}

variable "private-subnet3" {
  type    = string
  default = "10.10.3.0/24"
}

variable "public-subnet1" {
  type    = string
  default = "10.10.4.0/24"
}

variable "public-subnet2" {
  type    = string
  default = "10.10.5.0/24"
}

variable "public-subnet3" {
  type    = string
  default = "10.10.6.0/24"
}

variable "ec2-type" {
  type    = string
  default = "t3.micro"
}

variable "sg_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}