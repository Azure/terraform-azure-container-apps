output "container_app_environment_id" {
  description = "The ID of the Container App Environment within which this Container App should exist."
  value       = azurerm_container_app_environment.containerenv.id
}

output "container_app_fqdn" {
  description = "The FQDN of the Latest Revision of the Container App."
  value       = { for name, container in azurerm_container_app.containerapp : name => "http://${container.latest_revision_fqdn}" }
}