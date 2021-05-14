output "frontend_alb_arn" {
  value = aws_lb.frontend.arn
}

output "frontend_target_arn" {
  value = aws_lb_target_group.frontend.arn
}
