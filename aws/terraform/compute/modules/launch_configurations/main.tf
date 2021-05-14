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

resource "random_id" "conf" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    instance_type = var.instance_type
    key_name      = var.key_name
    user_data     = file("${path.module}/startup.sh")
    security_groups = join(" ", var.security_groups)
  }

  byte_length = 2
}

resource "aws_launch_configuration" "web_lauch_conf" {
  name          = "${var.organization}-${var.env}-web-launch-conf-${random_id.conf.hex}"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = random_id.conf.keepers.instance_type
  key_name      = random_id.conf.keepers.key_name

  associate_public_ip_address = true
  security_groups = split(" ", random_id.conf.keepers.security_groups)
  user_data       = random_id.conf.keepers.user_data

  lifecycle {
    create_before_destroy = true
  }
}
