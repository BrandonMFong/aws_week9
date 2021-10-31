# EC2
resource "aws_instance" "week9-bastion-vm" {
  ami                  = "ami-02e136e904f3da870"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.week9-sub-a.id

  vpc_security_group_ids = [
    aws_security_group.week9-ssh-sg-v2.id
  ]

  key_name = "ECE592"

  tags = {
    Name = "week9-bastion-vm"
  }
}
