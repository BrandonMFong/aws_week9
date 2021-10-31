# EC2
resource "aws_instance" "week9-bastion-vm" {
  ami                  = "ami-02e136e904f3da870"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.week9-sub-a.id
  iam_instance_profile = aws_iam_instance_profile.week9_iam_profile.name

  vpc_security_group_ids = [
    aws_security_group.week9-ssh-sg-v2.id
  ]

  key_name = "ECE592"

  tags = {
    Name = "week9-bastion-vm"
  }
}

# IAM profile ref
resource "aws_iam_instance_profile" "week9_iam_profile" {
  name = "week9_iam_profile"
  role = aws_iam_role.week9-role.name
  tags = {}
}
