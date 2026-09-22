output "public_ip" {
  description = "Public IP of the monitoring VM"
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_command" {
  description = "Ready to paste SSH command"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "prometheus_url" {
  value = "http://${azurerm_public_ip.main.ip_address}:9090"
}

output "grafana_url" {
  value = "http://${azurerm_public_ip.main.ip_address}:3000"
}
