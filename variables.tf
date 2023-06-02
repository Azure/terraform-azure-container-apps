variable "container_apps" {
  description = "The container apps to deploy."
  type = map(object({
    name          = string
    tags          = optional(map(string))
    revision_mode = string

    template = object({
      containers = set(object({
        name    = string
        image   = string
        args    = optional(list(string))
        command = optional(list(string))
        cpu     = string
        memory  = string
        env = optional(set(object({
          name        = string
          secret_name = optional(string)
          value       = /*optional?*/ string
        })))
        liveness_probe = optional(object({
          failure_count_threshold = optional(number)
          header = optional(object({
            name  = string
            value = string
          }))
          host             = optional(string)
          initial_delay    = optional(number, 1)
          interval_seconds = optional(number, 10)
          path             = optional(string)
          port             = number
          timeout          = optional(number, 1)
          transport        = string
        }))
        readiness_probe = optional(object({
          failure_count_threshold = optional(number)
          header = optional(object({
            name  = string
            value = string
          }))
          host                    = optional(string)
          interval_seconds        = optional(number, 10)
          path                    = optional(string)
          port                    = number
          success_count_threshold = optional(number, 3)
          timeout                 = optional(number)
          transport               = string
        }))
        startup_probe = optional(object({
          failure_count_threshold = optional(number)
          header = optional(object({
            name  = string
            value = string
          }))
          host             = optional(string)
          interval_seconds = optional(number, 10)
          path             = optional(string)
          port             = number
          timeout          = optional(number)
          transport        = string
        }))
        volume_mounts = optional(object({
          name = string
          path = string
        }))
      }))
      max_replicas    = optional(number)
      min_replicas    = optional(number)
      revision_suffix = optional(string)

      volume = optional(list(object({
        name         = string
        storage_name = optional(string)
        storage_type = optional(string)
      })))
    })

    ingress = optional(object({
      allow_insecure_connections = optional(bool, false)
      external_enabled           = optional(bool, false)
      target_port                = number
      transport                  = optional(string)
      traffic_weight = object({
        label           = optional(string)
        latest_revision = optional(string)
        revision_suffix = optional(string)
        percentage      = number
      })
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    dapr = optional(object({
      app_id       = string
      app_port     = number
      app_protocol = optional(string)
    }))

    registry = optional(list(object({
      server               = string
      username             = optional(string)
      password_secret_name = optional(string)
      identity             = optional(string)
    })))
  }))

  validation {
    condition     = length(var.container_apps) >= 1
    error_message = "At least one container should be provided."
  }
  nullable = false
}

variable "container_app_secrets" {
  description = "(Optional) The secrets of the container apps. The key of the map should be aligned with the corresponding container app."
  type = map(object({
    name  = string
    value = string
  }))
  default   = null
  sensitive = true
}

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace. Changing this forces a new resource to be created."
  type        = string
}

variable "container_app_environment_name" {
  description = "(Required) The name of the container apps managed environment. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which the resources will be created."
  type        = string
}

variable "log_analytics_workspace_allow_resource_only_permissions" {
  description = "(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to `true`."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_cmk_for_query_forced" {
  description = "(Optional) Is Customer Managed Storage mandatory for query management? Defaults to `false`."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_daily_quota_gb" {
  description = "(Optional) The workspace daily quota for ingestion in GB. Defaults to `-1` which means unlimited."
  type        = number
  default     = -1
}

variable "dapr_component" {
  description = "(Optional) The Dapr component to deploy."
  type = map(object({
    name           = string
    component_type = string
    version        = string
    ignore_errors  = optional(bool, false)
    init_timeout   = optional(string, "5s")
    scopes         = optional(list(string))
    metadata = optional(set(object({
      name        = string
      secret_name = optional(string)
      value       = string
    })))
  }))
  default  = {}
  nullable = false
}

variable "dapr_component_secrets" {
  description = "(Optional) The secrets of the Dapr components. The key of the map should be aligned with the corresponding Dapr component."
  type = map(object({
    name  = string
    value = string
  }))
  default   = null
  sensitive = true
}

variable "container_app_environment_tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "container_app_environment_infrastructure_subnet_id" {
  description = "(Optional) The existing subnet to use for the container apps control plane. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "container_app_environment_internal_load_balancer_enabled" {
  description = "(Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_internet_ingestion_enabled" {
  description = "(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to `true`."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_internet_query_enabled" {
  description = "(Optional) Should the Log Analytics Workspace support query over the Public Internet? Defaults to `true`."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_local_authentication_disabled" {
  description = "(Optional) Specifies if the log analytics workspace should enforce authentication using Azure Active Directory. Defaults to `false`."
  type        = bool
  default     = false
}

variable "location" {
  description = "(Required) The location this container app is deployed in. This should be the same as the environment in which it is deployed."
  type        = string
  default     = ""
}

variable "log_analytics_workspace" {
  description = "(Optional) A Log Analytics Workspace already exists."
  type = object({
    id = string
  })
  default = null
}

variable "log_analytics_workspace_sku" {
  description = "(Optional) Specifies the SKU of the Log Analytics Workspace. Possible values are `Free`, `PerNode`, `Premium`, `Standard`, `Standalone`, `Unlimited`, `CapacityReservation`, and `PerGB2018`(new SKU as of `2018-04-03`). Defaults to `PerGB2018`. "
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_workspace_tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = null
}

variable "log_analytics_workspace_reservation_capacity_in_gb_per_day" {
  description = "(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000. `reservation_capacity_in_gb_per_day` can only be used when the `sku` is set to `CapacityReservation`."
  type        = number
  default     = null
}

variable "log_analytics_workspace_retention_in_days" {
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
  type        = number
  default     = null
}