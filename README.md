# terraform-azurerm-container-apps

A Terraform module to deploy a container app in Azure with the following characteristics:

- Ability to specify all the parameters of log analytics workspace resource.
- Specify the container app image using `image` parameter in `template` block under `container_apps` variable.
- For multiple apps, specify the container parameters under `containers`. It's a set of objects with the following parameters:
  - `name` - (Required) The name of the container.
  - `image` - (Required) The container image.
  - `resources` - (Optional) The resource requirements for the container.
  - `ports` - (Optional) The ports exposed by the container.
  - `environment_variables` - (Optional) The environment variables for the container.
  - `command` - (Optional) The command to run within the container in exec form.
  - `args` - (Optional) The arguments to the command in `command` field.
  - `liveness_probe` - (Optional) The liveness probe for the container.
  - `readiness_probe` - (Optional) The readiness probe for the container.
  - `volume_mounts` - (Optional) The volume mounts for the container.
  - `volumes` - (Optional) The volumes for the container.
  - `secrets` - (Optional) The secrets for the container.
  - `image_pull_secrets` - (Optional) The image pull secrets for the container.
  - `security_context` - (Optional) The security context for the container.
  - `resources` - (Optional) The resource requirements for the container.
  - `ports` - (Optional) The ports exposed by the container.
  - `environment_variables` - (Optional) The environment variables for the container.
  - `command` - (Optional) The command to run within the container in exec form.
  - `args` - (Optional) The arguments to the command in `command` field.
  - `liveness_probe` - (Optional) The liveness probe for the container.


## Usage in Terraform 1.2.0

Please view folders in `examples`.

## Telemetry Collection

This module uses [terraform-provider-modtm](https://registry.terraform.io/providers/Azure/modtm/latest) to collect telemetry data. This provider is designed to assist with tracking the usage of Terraform modules. It creates a custom `modtm_telemetry` resource that gathers and sends telemetry data to a specified endpoint. The aim is to provide visibility into the lifecycle of your Terraform modules - whether they are being created, updated, or deleted. This data can be invaluable in understanding the usage patterns of your modules, identifying popular modules, and recognizing those that are no longer in use.

The ModTM provider is designed with respect for data privacy and control. The only data collected and transmitted are the tags you define in module's `modtm_telemetry` resource, an uuid which represents a module instance's identifier, and the operation the module's caller is executing (Create/Update/Delete/Read). No other data from your Terraform modules or your environment is collected or transmitted.

One of the primary design principles of the ModTM provider is its non-blocking nature. The provider is designed to work in a way that any network disconnectedness or errors during the telemetry data sending process will not cause a Terraform error or interrupt your Terraform operations. This makes the ModTM provider safe to use even in network-restricted or air-gaped environments.

If the telemetry data cannot be sent due to network issues, the failure will be logged, but it will not affect the Terraform operation in progress(it might delay your operations for no more than 5 seconds). This ensures that your Terraform operations always run smoothly and without interruptions, regardless of the network conditions.

You can turn off the telemetry collection by declaring the following `provider` block in your root module:

```hcl
provider "modtm" {
  enabled = false
}
```

## Pre-Commit & Pr-Check & Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

We assumed that you have setup service principal's credentials in your environment variables like below:

```shell
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

On Windows Powershell:

```shell
$env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
$env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
$env:ARM_CLIENT_ID="<service_principal_appid>"
$env:ARM_CLIENT_SECRET="<service_principal_password>"
```

We provide a docker image to run the pre-commit checks and tests for you: `mcr.microsoft.com/azterraform:latest`

To run the pre-commit task, we can run the following command:

```shell
$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit
```

On Windows Powershell:

```shell
$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit
```

In pre-commit task, we will:

1. Run `terraform fmt -recursive` command for your Terraform code.
2. Run `terrafmt fmt -f` command for markdown files and go code files to ensure that the Terraform code embedded in these files are well formatted.
3. Run `go mod tidy` and `go mod vendor` for test folder to ensure that all the dependencies have been synced.
4. Run `gofmt` for all go code files.
5. Run `gofumpt` for all go code files.
6. Run `terraform-docs` on `README.md` file, then run `markdown-table-formatter` to format markdown tables in `README.md`.

Then we can run the pr-check task to check whether our code meets our pipeline's requirement(We strongly recommend you run the following command before you commit):

```shell
$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pr-check
```

On Windows Powershell:

```shell
$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pr-check
```

To run the e2e-test, we can run the following command:

```text
docker run --rm -v $(pwd):/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test
```

On Windows Powershell:

```text
docker run --rm -v ${pwd}:/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test
```

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

## License

[MIT](LICENSE)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.98, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.98, < 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |
| [azurerm_container_app_environment.container_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_environment_dapr_component.dapr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_dapr_component) | resource |
| [azurerm_container_app_environment_storage.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_storage) | resource |
| [azurerm_log_analytics_workspace.laws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_container_app_environment.container_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app_environment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environment"></a> [container\_app\_environment](#input\_container\_app\_environment) | Reference to existing container apps environment to use. | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>  })</pre> | `null` | no |
| <a name="input_container_app_environment_infrastructure_subnet_id"></a> [container\_app\_environment\_infrastructure\_subnet\_id](#input\_container\_app\_environment\_infrastructure\_subnet\_id) | (Optional) The existing subnet to use for the container apps control plane. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_container_app_environment_internal_load_balancer_enabled"></a> [container\_app\_environment\_internal\_load\_balancer\_enabled](#input\_container\_app\_environment\_internal\_load\_balancer\_enabled) | (Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_container_app_environment_name"></a> [container\_app\_environment\_name](#input\_container\_app\_environment\_name) | (Required) The name of the container apps managed environment. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_container_app_environment_tags"></a> [container\_app\_environment\_tags](#input\_container\_app\_environment\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | `{}` | no |
| <a name="input_container_app_secrets"></a> [container\_app\_secrets](#input\_container\_app\_secrets) | (Optional) The secrets of the container apps. The key of the map should be aligned with the corresponding container app. | <pre>map(list(object({<br>    name                = string<br>    value               = optional(string, null)<br>    identity            = optional(string, null)<br>    key_vault_secret_id = optional(string, null)<br>  })))</pre> | `{}` | no |
| <a name="input_container_apps"></a> [container\_apps](#input\_container\_apps) | The container apps to deploy. | <pre>map(object({<br>    name                  = string<br>    tags                  = optional(map(string))<br>    revision_mode         = string<br>    workload_profile_name = optional(string)<br><br>    template = object({<br>      init_containers = optional(set(object({<br>        args    = optional(list(string))<br>        command = optional(list(string))<br>        cpu     = optional(number)<br>        image   = string<br>        name    = string<br>        memory  = optional(string)<br>        env = optional(list(object({<br>          name        = string<br>          secret_name = optional(string)<br>          value       = optional(string)<br>        })))<br>        volume_mounts = optional(list(object({<br>          name = string<br>          path = string<br>        })))<br>      })), [])<br>      containers = set(object({<br>        name    = string<br>        image   = string<br>        args    = optional(list(string))<br>        command = optional(list(string))<br>        cpu     = string<br>        memory  = string<br>        env = optional(set(object({<br>          name        = string<br>          secret_name = optional(string)<br>          value       = optional(string)<br>        })))<br>        liveness_probe = optional(object({<br>          failure_count_threshold = optional(number)<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>          host             = optional(string)<br>          initial_delay    = optional(number, 1)<br>          interval_seconds = optional(number, 10)<br>          path             = optional(string)<br>          port             = number<br>          timeout          = optional(number, 1)<br>          transport        = string<br>        }))<br>        readiness_probe = optional(object({<br>          failure_count_threshold = optional(number)<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>          host                    = optional(string)<br>          interval_seconds        = optional(number, 10)<br>          path                    = optional(string)<br>          port                    = number<br>          success_count_threshold = optional(number, 3)<br>          timeout                 = optional(number)<br>          transport               = string<br>        }))<br>        startup_probe = optional(object({<br>          failure_count_threshold = optional(number)<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>          host             = optional(string)<br>          interval_seconds = optional(number, 10)<br>          path             = optional(string)<br>          port             = number<br>          timeout          = optional(number)<br>          transport        = string<br>        }))<br>        volume_mounts = optional(list(object({<br>          name = string<br>          path = string<br>        })))<br>      }))<br>      max_replicas    = optional(number)<br>      min_replicas    = optional(number)<br>      revision_suffix = optional(string)<br>      custom_scale_rule = optional(list(object({<br>        custom_rule_type = string<br>        metadata         = map(string)<br>        name             = string<br>        authentication = optional(list(object({<br>          secret_name       = string<br>          trigger_parameter = string<br>        })))<br>      })))<br>      http_scale_rule = optional(list(object({<br>        concurrent_requests = string<br>        name                = string<br>        authentication = optional(list(object({<br>          secret_name       = string<br>          trigger_parameter = optional(string)<br>        })))<br>      })))<br>      volume = optional(set(object({<br>        name         = string<br>        storage_name = optional(string)<br>        storage_type = optional(string)<br>      })))<br>    })<br><br>    ingress = optional(object({<br>      allow_insecure_connections = optional(bool, false)<br>      external_enabled           = optional(bool, false)<br>      ip_security_restrictions = optional(list(object({<br>        action           = string<br>        ip_address_range = string<br>        name             = string<br>        description      = optional(string)<br>      })), [])<br>      target_port = number<br>      transport   = optional(string)<br>      traffic_weight = object({<br>        label           = optional(string)<br>        latest_revision = optional(string)<br>        revision_suffix = optional(string)<br>        percentage      = number<br>      })<br>    }))<br><br>    identity = optional(object({<br>      type         = string<br>      identity_ids = optional(list(string))<br>    }))<br><br>    dapr = optional(object({<br>      app_id       = string<br>      app_port     = number<br>      app_protocol = optional(string)<br>    }))<br><br>    registry = optional(list(object({<br>      server               = string<br>      username             = optional(string)<br>      password_secret_name = optional(string)<br>      identity             = optional(string)<br>    })))<br><br>  }))</pre> | n/a | yes |
| <a name="input_dapr_component"></a> [dapr\_component](#input\_dapr\_component) | (Optional) The Dapr component to deploy. | <pre>map(object({<br>    name           = string<br>    component_type = string<br>    version        = string<br>    ignore_errors  = optional(bool, false)<br>    init_timeout   = optional(string, "5s")<br>    scopes         = optional(list(string))<br>    metadata = optional(set(object({<br>      name        = string<br>      secret_name = optional(string)<br>      value       = string<br>    })))<br>  }))</pre> | `{}` | no |
| <a name="input_dapr_component_secrets"></a> [dapr\_component\_secrets](#input\_dapr\_component\_secrets) | (Optional) The secrets of the Dapr components. The key of the map should be aligned with the corresponding Dapr component. | <pre>map(list(object({<br>    name  = string<br>    value = string<br>  })))</pre> | `{}` | no |
| <a name="input_env_storage"></a> [env\_storage](#input\_env\_storage) | (Optional) Manages a Container App Environment Storage, writing files to this file share to make data accessible by other systems. | <pre>map(object({<br>    name         = string<br>    account_name = string<br>    share_name   = string<br>    access_mode  = string<br>  }))</pre> | `{}` | no |
| <a name="input_environment_storage_access_key"></a> [environment\_storage\_access\_key](#input\_environment\_storage\_access\_key) | (Optional) The Storage Account Access Key. The key of the map should be aligned with the corresponding environment storage. | `map(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location this container app is deployed in. This should be the same as the environment in which it is deployed. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | (Optional) A Log Analytics Workspace already exists. | <pre>object({<br>    id = string<br>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace_allow_resource_only_permissions"></a> [log\_analytics\_workspace\_allow\_resource\_only\_permissions](#input\_log\_analytics\_workspace\_allow\_resource\_only\_permissions) | (Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_cmk_for_query_forced"></a> [log\_analytics\_workspace\_cmk\_for\_query\_forced](#input\_log\_analytics\_workspace\_cmk\_for\_query\_forced) | (Optional) Is Customer Managed Storage mandatory for query management? Defaults to `false`. | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_daily_quota_gb"></a> [log\_analytics\_workspace\_daily\_quota\_gb](#input\_log\_analytics\_workspace\_daily\_quota\_gb) | (Optional) The workspace daily quota for ingestion in GB. Defaults to `-1` which means unlimited. | `number` | `-1` | no |
| <a name="input_log_analytics_workspace_internet_ingestion_enabled"></a> [log\_analytics\_workspace\_internet\_ingestion\_enabled](#input\_log\_analytics\_workspace\_internet\_ingestion\_enabled) | (Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to `true`. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_internet_query_enabled"></a> [log\_analytics\_workspace\_internet\_query\_enabled](#input\_log\_analytics\_workspace\_internet\_query\_enabled) | (Optional) Should the Log Analytics Workspace support query over the Public Internet? Defaults to `true`. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_local_authentication_disabled"></a> [log\_analytics\_workspace\_local\_authentication\_disabled](#input\_log\_analytics\_workspace\_local\_authentication\_disabled) | (Optional) Specifies if the log analytics workspace should enforce authentication using Azure Active Directory. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | (Optional) Specifies the name of the Log Analytics Workspace. Must set this variable if `var.log_analytics_workspace` is `null`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_reservation_capacity_in_gb_per_day"></a> [log\_analytics\_workspace\_reservation\_capacity\_in\_gb\_per\_day](#input\_log\_analytics\_workspace\_reservation\_capacity\_in\_gb\_per\_day) | (Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000. `reservation_capacity_in_gb_per_day` can only be used when the `sku` is set to `CapacityReservation`. | `number` | `null` | no |
| <a name="input_log_analytics_workspace_retention_in_days"></a> [log\_analytics\_workspace\_retention\_in\_days](#input\_log\_analytics\_workspace\_retention\_in\_days) | (Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730. | `number` | `null` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | (Optional) Specifies the SKU of the Log Analytics Workspace. Possible values are `Free`, `PerNode`, `Premium`, `Standard`, `Standalone`, `Unlimited`, `CapacityReservation`, and `PerGB2018`(new SKU as of `2018-04-03`). Defaults to `PerGB2018`. | `string` | `"PerGB2018"` | no |
| <a name="input_log_analytics_workspace_tags"></a> [log\_analytics\_workspace\_tags](#input\_log\_analytics\_workspace\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which the resources will be created. | `string` | n/a | yes |
| <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled) | Whether enable tracing tags that generated by BridgeCrew Yor. | `bool` | `false` | no |
| <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix) | Default prefix for generated tracing tags | `string` | `"avm_"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | The ID of the Container App Environment within which this Container App should exist. |
| <a name="output_container_app_fqdn"></a> [container\_app\_fqdn](#output\_container\_app\_fqdn) | The FQDN of the Container App's ingress. |
| <a name="output_container_app_identities"></a> [container\_app\_identities](#output\_container\_app\_identities) | The identities of the Container App, key is Container App's name. |
| <a name="output_container_app_ips"></a> [container\_app\_ips](#output\_container\_app\_ips) | The IPs of the Latest Revision of the Container App. |
| <a name="output_container_app_uri"></a> [container\_app\_uri](#output\_container\_app\_uri) | The URI of the Container App's ingress. |
| <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain) | The default domain of the Container App Environment. |
<!-- END_TF_DOCS -->
