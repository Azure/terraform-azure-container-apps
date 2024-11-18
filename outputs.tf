output "container_app_environment_id" {
  description = "The ID of the Container App Environment within which this Container App should exist."
  value       = local.container_app_environment_id
}

output "container_app_fqdn" {
  description = "The FQDN of the Container App's ingress."
  value       = local.fqdns
}

output "container_app_identities" {
  description = "The identities of the Container App, key is Container App's name."
  value = { for name, container in azurerm_container_app.container_app : name => length(container.identity) > 0 ? {
    type         = try(container.identity[0].type, "")
    identity_ids = try(container.identity[0].identity_ids, [])
    principal_id = try(container.identity[0].principal_id, "")
    tenant_id    = try(container.identity[0].tenant_id, "")
  } : null }
}

output "container_app_ips" {
  description = "The IPs of the Latest Revision of the Container App."
  value       = local.container_app_environment_static_ip_address
}

output "container_app_uri" {
  description = "The URI of the Container App's ingress."
  value       = local.uris
}

output "default_domain" {
  description = "The default domain of the Container App Environment."
  value       = local.container_app_environment_default_domain
}
