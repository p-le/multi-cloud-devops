output "public" {
  value = aws_subnet.public.id
}

output "private" {
  value = aws_subnet.private.id
}
