resource "aws_instance" "jumpserver" {
  ami                    = data.aws_ssm_parameter.amz_ami.value
  instance_type          = var.ec2-type
  subnet_id              = aws_subnet.public1.id
  key_name               = "myvpckey"
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
  tags = {
    Name = "JumpServer"
  }
}
