data "azurerm_resource_group" "azca" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "laws" {
  location                           = coalesce(var.location, data.azurerm_resource_group.azca.location)
  name                               = "LogAnalyticsWorkspace"
  resource_group_name                = var.resource_group_name
  allow_resource_only_permissions    = var.allow_resource_only_permissions
  cmk_for_query_forced               = var.cmk_for_query_forced
  daily_quota_gb                     = var.daily_quota_gb
  internet_ingestion_enabled         = var.internet_ingestion_enabled
  internet_query_enabled             = var.internet_query_enabled
  local_authentication_disabled      = var.local_authentication_disabled
  reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day
  retention_in_days                  = var.retention_in_days
  sku                                = var.log_analytics_workspace_sku
  tags                               = var.log_analytics_workspace_tags
}

resource "azurerm_container_app_environment" "containerenv" {
  name                           = var.managed_environment_name
  location                       = coalesce(var.location, data.azurerm_resource_group.azca.location)
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.laws.id
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  tags                           = var.environment_tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_container_app" "containerapp" {
  for_each = { for app in var.container_apps : app.name => app }

  name                         = each.key
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.containerenv.id
  tags                         = each.value.tags
  revision_mode                = each.value.revision_mode

  template {
    max_replicas    = each.value.template.max_replicas
    min_replicas    = each.value.template.min_replicas
    revision_suffix = each.value.template.revision_suffix

    dynamic "container" {
      for_each = each.value.template.containers

      content {
        name    = container.value.name
        image   = container.value.image
        args    = container.value.args
        command = container.value.command
        cpu     = container.value.cpu
        memory  = container.value.memory

        dynamic "env" {
          for_each = container.value.env

          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]

          content {
            failure_count_threshold = liveness_probe.value.failure_count_threshold
            host                    = liveness_probe.value.host
            initial_delay           = liveness_probe.value.initial_delay
            interval_seconds        = liveness_probe.value.interval_seconds
            path                    = liveness_probe.value.path
            port                    = liveness_probe.value.port
            timeout                 = liveness_probe.value.timeout
            transport               = liveness_probe.value.transport

            dynamic "header" {
              for_each = liveness_probe.value.header == null ? [] : [liveness_probe.value.header]

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe == null ? [] : [container.value.readiness_probe]

          content {
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            host                    = readiness_probe.value.host
            interval_seconds        = readiness_probe.value.interval_seconds
            path                    = readiness_probe.value.path
            port                    = readiness_probe.value.port
            success_count_threshold = readiness_probe.value.success_count_threshold
            timeout                 = readiness_probe.value.timeout
            transport               = readiness_probe.value.transport

            dynamic "header" {
              for_each = readiness_probe.value.header == null ? [] : [readiness_probe.value.header]

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
        dynamic "startup_probe" {
          for_each = container.value.startup_probe == null ? [] : [container.value.startup_probe]

          content {
            failure_count_threshold = startup_probe.value.failure_count_threshold
            host                    = startup_probe.value.host
            interval_seconds        = startup_probe.value.interval_seconds
            path                    = startup_probe.value.path
            port                    = startup_probe.value.port
            timeout                 = startup_probe.value.timeout
            transport               = startup_probe.value.transport

            dynamic "header" {
              for_each = startup_probe.value.header == null ? [] : [startup_probe.value.header]

              content {
                name  = header.value.name
                value = header.value.name
              }
            }
          }
        }
        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts == null ? [] : [container.value.volume_mounts]

          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }
    dynamic "volume" {
      for_each = each.value.template.volume == null ? [] : [each.value.template.volume]

      content {
        name         = volume.value.name
        storage_name = volume.value.storage_name
        storage_type = volume.value.storage_type
      }
    }
  }

  dynamic "ingress" {
    for_each = each.value.ingress == null ? [] : [each.value.ingress]

    content {
      allow_insecure_connections = ingress.value.allow_insecure_connections
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = ingress.value.transport

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight == null ? [] : [ingress.value.traffic_weight]

        content {
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
          percentage      = traffic_weight.value.percentage
        }
      }
    }
  }

  dynamic "identity" {
    for_each = each.value.identity == null ? [] : [each.value.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "dapr" {
    for_each = each.value.dapr == null ? [] : [each.value.dapr]

    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  dynamic "secret" {
    for_each = each.value.secret == null ? [] : [each.value.secret]

    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
