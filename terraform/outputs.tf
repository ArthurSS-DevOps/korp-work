output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.korp.id
}

output "private_ip" {
  description = "IP privado fixo da EC2"
  value       = aws_network_interface.korp.private_ip
}

output "elastic_ip" {
  description = "Elastic IP público"
  value       = aws_eip.korp.public_ip
}

output "ssh_command" {
  description = "Comando SSH para Debian"
  value       = "ssh admin@${aws_eip.korp.public_ip}"
}

output "application_url" {
  description = "URL da aplicação"
  value       = "http://${aws_eip.korp.public_ip}/projeto-korp"
}

output "grafana_url" {
  description = "URL do Grafana"
  value       = "http://${aws_eip.korp.public_ip}:3000"
}

output "prometheus_url" {
  description = "URL do Prometheus"
  value       = "http://${aws_eip.korp.public_ip}:9090"
}