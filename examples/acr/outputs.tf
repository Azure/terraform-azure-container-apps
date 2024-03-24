output "app_url" {
  value = module.container_apps.container_app_uri
}
ouput "app_fqdn" {
  value = module.container_apps.container_app_fqdn
}
output "default_domain" {
  value = module.container_apps.default_domain
}
