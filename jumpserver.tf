resource "aws_instance" "jumpserver" {
  ami                    = data.aws_ssm_parameter.amz_ami.value
  instance_type          = var.ec2-type
  subnet_id              = element(aws_subnet.public[*].id, 0)
  key_name               = "myvpckey"
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
  tags = {
    Name = "JumpServer"
  }
}
