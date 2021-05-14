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

resource "aws_placement_group" "normal" {
  name     = "${var.organization}-${var.env}-normal-pg"
  strategy = "cluster"
}

resource "aws_placement_group" "partition" {
  name     = "${var.organization}-${var.env}-partition-pg"
  strategy = "partition"
}

resource "aws_placement_group" "spread" {
  name     = "${var.organization}-${var.env}-spread-pg"
  strategy = "spread"
}

resource "aws_launch_template" "normal" {
  name        = "${var.organization}-${var.env}-normal-launch-template"
  description = "[${upper(var.env)}] Normal Launch Template"
  image_id    = data.aws_ami.amazon_linux_2.id

  instance_type = "t3.small"
  key_name      = var.key_name

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  # t3.nano: maximum network interfaces 2
  # t3.small: maximum network interfaces 3 -> OK
  dynamic "network_interfaces" {
    for_each = var.subnets
    content {
      # Cannot use associate_public_ip_address when using multiple network interfaces
      # associate_public_ip_address = network_interfaces.key == 0 ? true : false
      subnet_id = network_interfaces.value
      device_index = network_interfaces.key
    }
  }

  # placement {
  #   # Lauch template contains Availability Zone -> EC2-Classic
  #   # availability_zone = var.availability_zone
  #   group_name = aws_placement_group.normal.id
  # }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.organization}-${var.env}-instance"
    }
  }

  user_data = filebase64("${path.module}/startup.sh")
}
