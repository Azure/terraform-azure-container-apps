variable "container_app_environment_name" {
  type        = string
  description = "(Required) The name of the container apps managed environment. Changing this forces a new resource to be created."
  nullable    = false
}

variable "container_apps" {
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
          value       = optional(string)
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

      volume = optional(set(object({
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
  description = "The container apps to deploy."
  nullable    = false

  validation {
    condition     = length(var.container_apps) >= 1
    error_message = "At least one container should be provided."
  }
}

variable "location" {
  type        = string
  description = "(Required) The location this container app is deployed in. This should be the same as the environment in which it is deployed."
  nullable    = false
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "(Required) Specifies the name of the Log Analytics Workspace. Changing this forces a new resource to be created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the resources will be created."
  nullable    = false
}

variable "container_app_environment_infrastructure_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The existing subnet to use for the container apps control plane. Changing this forces a new resource to be created."
}

variable "container_app_environment_internal_load_balancer_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Changing this forces a new resource to be created."
}

variable "container_app_environment_tags" {
  type        = map(string)
  default     = {}
  description = "A map of the tags to use on the resources that are deployed with this module."
}

variable "container_app_secrets" {
  type = map(list(object({
    name  = string
    value = string
  })))
  default     = {}
  description = "(Optional) The secrets of the container apps. The key of the map should be aligned with the corresponding container app."
  nullable    = false
  sensitive   = true
}

variable "dapr_component" {
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
  default     = {}
  description = "(Optional) The Dapr component to deploy."
  nullable    = false
}

variable "dapr_component_secrets" {
  type = map(list(object({
    name  = string
    value = string
  })))
  default     = {}
  description = "(Optional) The secrets of the Dapr components. The key of the map should be aligned with the corresponding Dapr component."
  nullable    = false
  sensitive   = true
}

variable "env_storage" {
  type = map(object({
    name         = string
    account_name = string
    share_name   = string
    access_mode  = string
  }))
  default     = {}
  description = "(Optional) Manages a Container App Environment Storage, writing files to this file share to make data accessible by other systems."
  nullable    = false
}

variable "environment_storage_access_key" {
  type        = map(string)
  default     = null
  description = "(Optional) The Storage Account Access Key. The key of the map should be aligned with the corresponding environment storage."
  sensitive   = true
}

variable "log_analytics_workspace" {
  type = object({
    id = string
  })
  default     = null
  description = "(Optional) A Log Analytics Workspace already exists."
}

variable "log_analytics_workspace_allow_resource_only_permissions" {
  type        = bool
  default     = true
  description = "(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to `true`."
}

variable "log_analytics_workspace_cmk_for_query_forced" {
  type        = bool
  default     = false
  description = "(Optional) Is Customer Managed Storage mandatory for query management? Defaults to `false`."
}

variable "log_analytics_workspace_daily_quota_gb" {
  type        = number
  default     = -1
  description = "(Optional) The workspace daily quota for ingestion in GB. Defaults to `-1` which means unlimited."
}

variable "log_analytics_workspace_internet_ingestion_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to `true`."
}

variable "log_analytics_workspace_internet_query_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Should the Log Analytics Workspace support query over the Public Internet? Defaults to `true`."
}

variable "log_analytics_workspace_local_authentication_disabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies if the log analytics workspace should enforce authentication using Azure Active Directory. Defaults to `false`."
}

variable "log_analytics_workspace_reservation_capacity_in_gb_per_day" {
  type        = number
  default     = null
  description = "(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000. `reservation_capacity_in_gb_per_day` can only be used when the `sku` is set to `CapacityReservation`."
}

variable "log_analytics_workspace_retention_in_days" {
  type        = number
  default     = null
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "(Optional) Specifies the SKU of the Log Analytics Workspace. Possible values are `Free`, `PerNode`, `Premium`, `Standard`, `Standalone`, `Unlimited`, `CapacityReservation`, and `PerGB2018`(new SKU as of `2018-04-03`). Defaults to `PerGB2018`. "
}

variable "log_analytics_workspace_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
}
