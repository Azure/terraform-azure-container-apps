resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-container-app-${random_id.rg_name.hex}"
}

module "containerapps" {
  source                         = "../.."
  resource_group_name            = azurerm_resource_group.test.name
  location                       = var.location
  container_app_environment_name = "example-env-${random_id.env_name.hex}"

  container_apps = {
    example = {
      name          = "example-container"
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "countingservicetest1"
            memory = "0.5Gi"
            cpu    = 0.25
            image  = "docker.io/hashicorp/counting-service:0.0.2"
            env = [
              {
                name  = "PORT"
                value = "9001"
              }
            ]
          }
        ]
      }

      ingress = {
        allow_insecure_connections = true
        external_enabled           = true
        target_port                = 9001
        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
      }
    }
  }
  log_analytics_workspace_name = "testlaws"
  container_app_secrets        = {}
  dapr_component_secrets       = {}
}

resource "azurerm_container_app" "dashboard" {
  container_app_environment_id = module.containerapps.container_app_environment_id
  name                         = "dashboardtest"
  resource_group_name          = azurerm_resource_group.test.name
  revision_mode                = "Single"

  template {
    container {
      name   = "testdashboard"
      image  = "docker.io/hashicorp/dashboard-service:0.0.4"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "PORT"
        value = "8080"
      }
      env {
        name  = "COUNTING_SERVICE_URL"
        value = module.containerapps.container_app_fqdn["example"]
      }
    }
  }

  ingress {
    allow_insecure_connections = true
    target_port                = 8080
    external_enabled           = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  identity {
    type = "SystemAssigned"
  }
}