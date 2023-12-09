output "container_app_environment_id" {
  description = "The ID of the Container App Environment within which this Container App should exist."
  value       = local.container_app_environment_id
}

output "container_app_fqdn" {
  description = "The FQDN of the Container App's ingress."
  value       = { for name, container in azurerm_container_app.container_app : name => "https://${try(container.ingress[0].fqdn, "")}" if can(container.ingress[0].fqdn) }
}

output "container_app_ips" {
  description = "The IPs of the Latest Revision of the Container App."
  value       = try(azurerm_container_app_environment.container_env[0].static_ip_address, data.azurerm_container_app_environment.container_env.static_ip_address)
}
