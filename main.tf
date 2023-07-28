resource "azurerm_log_analytics_workspace" "laws" {
  count = var.log_analytics_workspace == null ? 1 : 0

  location                           = var.location
  name                               = var.log_analytics_workspace_name
  resource_group_name                = var.resource_group_name
  allow_resource_only_permissions    = var.log_analytics_workspace_allow_resource_only_permissions
  cmk_for_query_forced               = var.log_analytics_workspace_cmk_for_query_forced
  daily_quota_gb                     = var.log_analytics_workspace_daily_quota_gb
  internet_ingestion_enabled         = var.log_analytics_workspace_internet_ingestion_enabled
  internet_query_enabled             = var.log_analytics_workspace_internet_query_enabled
  local_authentication_disabled      = var.log_analytics_workspace_local_authentication_disabled
  reservation_capacity_in_gb_per_day = var.log_analytics_workspace_reservation_capacity_in_gb_per_day
  retention_in_days                  = var.log_analytics_workspace_retention_in_days
  sku                                = var.log_analytics_workspace_sku
  tags                               = var.log_analytics_workspace_tags
}

resource "azurerm_container_app_environment" "container_env" {
  location                       = var.location
  log_analytics_workspace_id     = try(azurerm_log_analytics_workspace.laws[0].id, var.log_analytics_workspace.id)
  name                           = var.container_app_environment_name
  resource_group_name            = var.resource_group_name
  infrastructure_subnet_id       = var.container_app_environment_infrastructure_subnet_id
  internal_load_balancer_enabled = var.container_app_environment_internal_load_balancer_enabled
  tags                           = var.container_app_environment_tags
}

resource "azurerm_container_app_environment_dapr_component" "dapr" {
  for_each = var.dapr_component

  component_type               = each.value.component_type
  container_app_environment_id = azurerm_container_app_environment.container_env.id
  name                         = each.value.name
  version                      = each.value.version
  ignore_errors                = each.value.ignore_errors
  init_timeout                 = each.value.init_timeout
  scopes                       = each.value.scopes

  dynamic "metadata" {
    for_each = each.value.metadata == null ? [] : each.value.metadata

    content {
      name        = metadata.value.name
      secret_name = metadata.value.secret_name
      value       = metadata.value.value
    }
  }
  dynamic "secret" {
    for_each = nonsensitive(toset([for pair in lookup(var.dapr_component_secrets, each.key, []) : pair.name]))

    content {
      name  = secret.key
      value = local.dapr_component_secrets[each.key][secret.key]
    }
  }
}

resource "azurerm_container_app_environment_storage" "storage" {
  for_each = var.env_storage

  access_key                   = var.environment_storage_access_key[each.key]
  access_mode                  = each.value.access_mode
  account_name                 = each.value.account_name
  container_app_environment_id = azurerm_container_app_environment.container_env.id
  name                         = each.value.name
  share_name                   = each.value.share_name
}

resource "azurerm_container_app" "container_app" {
  for_each = var.container_apps

  container_app_environment_id = azurerm_container_app_environment.container_env.id
  name                         = each.value.name
  resource_group_name          = var.resource_group_name
  revision_mode                = each.value.revision_mode
  tags                         = each.value.tags

  template {
    max_replicas    = each.value.template.max_replicas
    min_replicas    = each.value.template.min_replicas
    revision_suffix = each.value.template.revision_suffix

    dynamic "container" {
      for_each = each.value.template.containers

      content {
        cpu     = container.value.cpu
        image   = container.value.image
        memory  = container.value.memory
        name    = container.value.name
        args    = container.value.args
        command = container.value.command

        dynamic "env" {
          for_each = container.value.env == null ? [] : container.value.env

          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]

          content {
            port                    = liveness_probe.value.port
            transport               = liveness_probe.value.transport
            failure_count_threshold = liveness_probe.value.failure_count_threshold
            host                    = liveness_probe.value.host
            initial_delay           = liveness_probe.value.initial_delay
            interval_seconds        = liveness_probe.value.interval_seconds
            path                    = liveness_probe.value.path
            timeout                 = liveness_probe.value.timeout

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
            port                    = readiness_probe.value.port
            transport               = readiness_probe.value.transport
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            host                    = readiness_probe.value.host
            interval_seconds        = readiness_probe.value.interval_seconds
            path                    = readiness_probe.value.path
            success_count_threshold = readiness_probe.value.success_count_threshold
            timeout                 = readiness_probe.value.timeout

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
            port                    = startup_probe.value.port
            transport               = startup_probe.value.transport
            failure_count_threshold = startup_probe.value.failure_count_threshold
            host                    = startup_probe.value.host
            interval_seconds        = startup_probe.value.interval_seconds
            path                    = startup_probe.value.path
            timeout                 = startup_probe.value.timeout

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
      for_each = each.value.template.volume == null ? [] : each.value.template.volume

      content {
        name         = volume.value.name
        storage_name = volume.value.storage_name
        storage_type = volume.value.storage_type
      }
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
  dynamic "identity" {
    for_each = each.value.identity == null ? [] : [each.value.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "ingress" {
    for_each = each.value.ingress == null ? [] : [each.value.ingress]

    content {
      target_port                = ingress.value.target_port
      allow_insecure_connections = ingress.value.allow_insecure_connections
      external_enabled           = ingress.value.external_enabled
      transport                  = ingress.value.transport

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight == null ? [] : [ingress.value.traffic_weight]

        content {
          percentage      = traffic_weight.value.percentage
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
        }
      }
    }
  }
  dynamic "registry" {
    for_each = each.value.registry == null ? [] : each.value.registry

    content {
      server               = registry.value.server
      identity             = registry.value.identity
      password_secret_name = registry.value.password_secret_name
      username             = registry.value.username
    }
  }
  dynamic "secret" {
    for_each = nonsensitive(toset([for pair in lookup(var.container_app_secrets, each.key, []) : pair.name]))

    content {
      name  = secret.key
      value = local.container_app_secrets[each.key][secret.key]
    }
  }
}
