resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = "docker login -u ${azurerm_container_registry.acr.admin_username} -p ${azurerm_container_registry.acr.admin_password} https://${azurerm_container_registry.acr.login_server}"
  }
  provisioner "local-exec" {
    command = "docker tag nginx ${docker_tag.nginx.target_image}"
  }
  provisioner "local-exec" {
    command = "docker push ${docker_tag.nginx.target_image}"
  }
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-container-app-${random_id.rg_name.hex}"
}

resource "azurerm_container_registry" "acr" {
  #checkov:skip=CKV_AZURE_139: Public network access is required for the test
  #checkov:skip=CKV_AZURE_137: Admin enabled is required for the test
  location                      = azurerm_resource_group.test.location
  name                          = "acr${random_id.container_name.hex}"
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Premium"
  admin_enabled                 = true
  public_network_access_enabled = true

  retention_policy {
    days    = 7
    enabled = true
  }
  trust_policy {
    enabled = true
  }
  georeplications {
    location                = "West Europe"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  georeplications {
    location                = "North Europe"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  quarantine_policy_enabled = true
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_tag" "nginx" {
  source_image = docker_image.nginx.name
  target_image = "${azurerm_container_registry.acr.login_server}/${docker_image.nginx.name}"
}

provider "docker" {
  alias = "acr"
}

module "container_apps" {
  source = "../.."

  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  log_analytics_workspace_name   = "loganalytics-${random_id.rg_name.hex}"
  container_app_environment_name = "example-env-${random_id.env_name.hex}"

  container_apps = {
    nginx = {
      name          = "nginx"
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "nginx"
            memory = "0.5Gi"
            cpu    = 0.25
            image  = "${azurerm_container_registry.acr.login_server}/${docker_image.nginx.name}"
          }
        ]
      }

      registry = [
        {
          server               = azurerm_container_registry.acr.login_server
          username             = azurerm_container_registry.acr.admin_username
          password_secret_name = "secname"
        }
      ]
    }
  }

  container_app_secrets = {
    nginx = [
      {
        name  = "secname"
        value = azurerm_container_registry.acr.admin_password
      }
    ]
  }
}
