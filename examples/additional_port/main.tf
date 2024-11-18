resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-container-app-${random_id.rg_name.hex}"
}


resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  name                = "virtualnetwork1"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet" {
  address_prefixes                              = ["10.0.0.0/16"]
  name                                          = "subnet1"
  resource_group_name                           = azurerm_resource_group.test.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = false
}

locals {
  counting_app_name  = "counting-${random_id.container_name.hex}"
  dashboard_app_name = "dashboard-${random_id.container_name.hex}"
}

module "container_apps" {
  source                                             = "../.."
  resource_group_name                                = azurerm_resource_group.test.name
  location                                           = var.location
  container_app_environment_name                     = "example-env-${random_id.env_name.hex}"
  container_app_environment_infrastructure_subnet_id = azurerm_subnet.subnet.id
  container_apps = {
    dashboard = {
      name          = local.dashboard_app_name
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "testdashboard"
            memory = "1Gi"
            cpu    = 0.5
            image  = "docker.io/hashicorp/dashboard-service:0.0.4"
            env = [
              {
                name  = "PORT"
                value = "8080"
              },
              {
                name  = "COUNTING_SERVICE_URL"
                value = "http://${local.counting_app_name}"
              }
            ]
          },
        ]
      }

      ingress = {
        allow_insecure_connections = false
        target_port                = 8080
        external_enabled           = true
        transport                  = "tcp"
        additional_port_mappings = [{
          external     = true
          target_port  = 8082
          exposed_port = 8082
        }]
        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
      }
      identity = {
        type = "SystemAssigned"
      }
    },
  }
  log_analytics_workspace_name = "testlaws"
}