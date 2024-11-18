output "dashboard_url" {
  value = try(module.container_apps.container_app_uri["dashboard"], "")
}
