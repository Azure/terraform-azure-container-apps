locals {
  container_app_secrets  = { for k, v in var.container_app_secrets : k => { for i in v : i.name => i.value } }
  dapr_component_secrets = { for k, v in var.dapr_component_secrets : k => { for i in v : i.name => i.value } }
}