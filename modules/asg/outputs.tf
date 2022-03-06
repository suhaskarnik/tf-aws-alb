output "id" {
  value = aws_autoscaling_group.this.id
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

