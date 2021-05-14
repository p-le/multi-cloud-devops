
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = [
    "amazon"
  ]
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "phule-devops-tf"
  }
}

resource "aws_internet_gateway" "public_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "phule-devops-gw-tf"
  }
}

resource "aws_route_table" "phule" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gw.id
  }

  tags = {
    Name = "phule-devops-rt-tf"
  }
}

resource "aws_subnet" "phule" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "phule-devops-subnet-tf"
  }
}

resource "aws_network_interface" "primary" {
  subnet_id   = aws_subnet.phule.id
  private_ips = ["172.16.10.100"]

  security_groups = [
    aws_security_group.allow_ssh.id
  ]

  tags = {
    Name = "phule-devops-primary-ni-tf"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "phule-devops-allow-ssh-tf"
  }
}

resource "aws_instance" "phule" {
  instance_type = "t3.micro"

  ami = data.aws_ami.amazon_linux_2.id

  network_interface {
    network_interface_id = aws_network_interface.primary.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "phule-devops-tf"
  }

  key_name  = "devops-ec2"

  depends_on = [
    aws_internet_gateway.public_gw
  ]
}
