resource "aws_autoscaling_group" "asg_launch_template" {
  name                = "${var.organization}-${var.env}-asg-using-launch-template"
  # Need to matchs with availability zones of subnet
  # For EC2-Classic
  availability_zones  = var.availability_zones
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0

  launch_template {
    id      = var.launch_template
    version = "$Latest"
  }
}


resource "aws_autoscaling_group" "asg_launch_conf" {
  name                  = "${var.organization}-${var.env}-asg-using-launch-conf"
  launch_configuration  = var.launch_configuration
  desired_capacity      = 2
  max_size              = 5
  min_size              = 2
  vpc_zone_identifier   = var.subnets // Conflict with availability_zones

  target_group_arns  = [
    var.frontend_target_arn
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}
