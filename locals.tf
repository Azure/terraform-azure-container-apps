locals {
  container_app_secrets  = { for k, v in var.container_app_secrets : k => { for i in v : i.name => i } }
  dapr_component_secrets = { for k, v in var.dapr_component_secrets : k => { for i in v : i.name => i.value } }
  fqdns                  = { for name, container in azurerm_container_app.container_app : name => try(container.ingress[0].fqdn, "") if can(container.ingress[0].fqdn) }
  uris                   = { for name, fqdn in local.fqdns : name => "https://${fqdn}" }
}