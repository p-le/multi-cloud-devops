locals {
  access_log_bucket = "phule-lb-logs"
  domain_name       = "coupon-savings.com"
}

data "aws_caller_identity" "main" {}
data "aws_elb_service_account" "main" {}
data "aws_route53_zone" "primary" {
  name  = "${local.domain_name}."
}

resource "aws_route53_record" "www" {
  name    = local.domain_name
  zone_id = data.aws_route53_zone.primary.zone_id
  type    = "A"

  alias {
    name                   = aws_lb.frontend.dns_name
    zone_id                = aws_lb.frontend.zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "access_logs" {
  bucket = local.access_log_bucket

  policy = templatefile("${path.module}/policy.json", {
    bucket = local.access_log_bucket
    prefix = "${var.organization}-${var.env}-frontend"
    elb_account_id = data.aws_elb_service_account.main.id
    aws_account_id = data.aws_caller_identity.main.account_id
  })

  lifecycle_rule {
    enabled = true
    prefix = "${var.organization}-${var.env}-frontend"
    expiration {
      days = 5
    }
  }
}

resource "aws_lb" "frontend" {
  name               = "${var.organization}-${var.env}-frontend-alb"
  internal           = false
  load_balancer_type = "application"

  // Only valid for Application Load Balancer
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.access_logs.bucket
    prefix  = "${var.organization}-${var.env}-frontend"
    enabled = true
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_target_group" "frontend" {
  name      = "${var.organization}-${var.env}-frontend-target"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = var.vpc_id

  deregistration_delay  = 300
  slow_start            = 30
  target_type           = "instance"

  health_check {
    path = "/"
  }
}
