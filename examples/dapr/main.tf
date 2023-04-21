resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "random_id" "keyvault_name" {
  byte_length = 8
}

resource "random_id" "sa_name" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "rg-${random_id.rg_name.hex}"
}

data "azurerm_client_config" "current" {}

data "curl" "public_ip" {
  http_method = "GET"
  uri         = "https://api.ipify.org?format=json"
}

locals {
  public_ip = jsondecode(data.curl.public_ip.response).ip
}

resource "azurerm_key_vault" "test" {
  location                 = azurerm_resource_group.rg.location
  name                     = "testkv${random_id.keyvault_name.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = "premium"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.public_ip, "0.0.0.0/0"]
  }

  depends_on = [azurerm_storage_container.test]
}

resource "azurerm_key_vault_key" "test" {
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  key_type        = "RSA-HSM"
  key_vault_id    = azurerm_key_vault.test.id
  name            = "testkey"
  expiration_date = "2025-01-02T15:04:05Z"
  key_size        = 2048

  depends_on = [azurerm_key_vault_access_policy.client, azurerm_key_vault_access_policy.storage]
}

resource "azurerm_log_analytics_workspace" "test" {
  location            = azurerm_resource_group.rg.location
  name                = "testlaworkspace"
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id        = azurerm_key_vault.test.id
  object_id           = azurerm_storage_account.test.identity[0].principal_id
  tenant_id           = azurerm_storage_account.test.identity[0].tenant_id
  key_permissions     = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "List", "Set", "Update", "RegenerateKey", "Recover", "Purge"]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.test.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions     = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "List", "Set", "Update", "RegenerateKey", "Recover", "Purge"]
}

resource "azurerm_storage_account" "test" {
  account_replication_type = "RAGRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.rg.location
  name                     = "testsa${random_id.sa_name.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  min_tls_version          = "TLS1_2"

  identity {
    type = "SystemAssigned"
  }
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = [local.public_ip, "0.0.0.0/0"]
  }
  queue_properties {
    logging {
      delete  = true
      read    = true
      version = "1.0"
      write   = true
    }
  }
}

resource "azurerm_log_analytics_storage_insights" "test" {
  name                 = "teststorageinsights"
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_id   = azurerm_storage_account.test.id
  storage_account_key  = azurerm_storage_account.test.primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.test.id
  blob_container_names = ["blobExample"]
}

resource "azurerm_storage_account_customer_managed_key" "managedkey" {
  key_name           = azurerm_key_vault_key.test.name
  key_vault_id       = azurerm_key_vault.test.id
  storage_account_id = azurerm_storage_account.test.id
  key_version        = azurerm_key_vault_key.test.version
}

resource "azurerm_storage_container" "test" {
  #checkov:skip=CKV2_AZURE_21:lll
  name                  = "testcontainer"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "test" {
  location            = azurerm_resource_group.rg.location
  name                = "testidentity"
  resource_group_name = azurerm_resource_group.rg.name
}

module "containerapps" {
  source                       = "../.."
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  managed_environment_name     = "example-env-${random_id.env_name.hex}"
  log_analytics_workspace_name = "testlaworkspace"
  dapr_component = [
    {
      name           = "statestore"
      component_type = "state.azure.blobstorage"
      version        = "v1"
      scopes         = ["nodeapp"]
      metadata = [
        {
          name  = "accountName"
          value = azurerm_storage_account.test.name
        },
        {
          name  = "containerName"
          value = azurerm_storage_container.test.name
        },
        {
          name  = "azureClientId"
          value = azurerm_user_assigned_identity.test.client_id
        }
      ]
    }
  ]
  container_apps = [
    {
      name          = "pythonapp"
      revision_mode = "Single"

      template = {
        dapr = {
          app_id   = "pythonapp"
          app_port = 0
        }
        containers = [
          {
            name   = "pythonapp"
            cpu    = 0.25
            image  = "dapriosamples/hello-k8s-python:latest"
            memory = "0.5Gi"
          }
        ]
      }
    },
    {
      name          = "nodeapp"
      revision_mode = "Single"

      template = {
        dapr = {
          app_id   = "nodeapp"
          app_port = 3000
        }
        identity = {
          type                      = "UserAssigned"
          user_assigned_identity_id = azurerm_user_assigned_identity.test.id
        }
        containers = [
          {
            name   = "nodeapp"
            cpu    = 0.25
            image  = "dapriosamples/hello-k8s-node:latest"
            memory = "0.5Gi"
            env = [
              {
                name  = "APP_PORT"
                value = "3000"
              }
            ]
          }
        ]
      }
    }
  ]
}