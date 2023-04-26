provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "existing_rg" {
  name = "myResourceGroup"
}

resource "azurerm_storage_account" "functionapp_sa" {
  name                     = "functionappstorage"
  resource_group_name      = data.azurerm_resource_group.existing_rg.name
  location                 = data.azurerm_resource_group.existing_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "functionapp_plan" {
  name                = "myFunctionAppPlan"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "delete_all_posts_function" {
  name                       = "delete-all-posts-function"
  location                   = data.azurerm_resource_group.existing_rg.location
  resource_group_name        = data.azurerm_resource_group.existing_rg.name
  app_service_plan_id        = azurerm_app_service_plan.functionapp_plan.id
  storage_account_name       = azurerm_storage_account.functionapp_sa.name
  storage_account_access_key = azurerm_storage_account.functionapp_sa.primary_access_key
  version                    = "~3"

  app_settings = {
    # Set any required environment variables for your function here
  }
}

resource "azurerm_function_app_source_control" "delete_all_posts_function_src" {
  function_app_id      = azurerm_function_app.delete_all_posts_function.id
  repo_url             = "https://github.com/todorovc/ghost_blog.git"
  branch               = "main"
  manual_integration   = true
  rollback_enabled     = false
  use_mercurial        = false
}
