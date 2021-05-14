output "allow_outbound" {
  value = aws_security_group.allow_outbound.id
}

output "allow_ssh" {
  value = aws_security_group.allow_ssh.id
}

output "allow_http" {
  value = aws_security_group.allow_http.id
}

output "allow_https" {
  value = aws_security_group.allow_https.id
}
