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
  name     = "example-container-app-${random_id.rg_name.hex}-init-container"
}

module "container_apps" {
  source                         = "../.."
  resource_group_name            = azurerm_resource_group.test.name
  location                       = var.location
  container_app_environment_name = "example-env-${random_id.env_name.hex}"

  container_apps = {
    example = {
      name          = "example"
      revision_mode = "Single"

      template = {
        init_containers = [
          {
            name   = "debian"
            image  = "debian:latest"
            memory = "0.5Gi"
            cpu    = 0.25
            command = [
              "/bin/sh",
            ]
            args = [
              "-c", "echo Hello from the debian container > /shared/index.html"
            ]
            volume_mounts = [
              {
                name = "shared"
                path = "/shared"
              }
            ]
          }
        ],
        containers = [
          {
            name   = "nginx"
            image  = "nginx:latest"
            memory = "1Gi"
            cpu    = 0.5
            volume_mounts = {
              name = "shared"
              path = "/usr/share/nginx/html"
            }
          }
        ],
        volume = [
          {
            name         = "shared"
            storage_type = "EmptyDir"
          }
        ]
      }


      ingress = {
        allow_insecure_connections = false
        target_port                = 80
        external_enabled           = true

        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
      }
    },
  }
  log_analytics_workspace_name = "container-app-module-lawn-${random_id.container_name.hex}"
}