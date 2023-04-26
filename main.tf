terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
  }
  }
}
provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "myResourceGroup"
  location            = "westeurope"
  acr_name            = "myhelmacr9"
  aks_cluster_name    = "myAKSCluster"
  app_gateway_name    = "dsrgateway"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${local.aks_cluster_name}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Terraform    = "true"
    Environment  = "dev"
  }

  depends_on = [azurerm_container_registry.acr]
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id   = azurerm_kubernetes_cluster.aks.identity.0.principal_id
  role_definition_name = "AcrPull"
  scope          = azurerm_container_registry.acr.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "myAppGwSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "myAppGwPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = local.app_gateway_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "myGatewayIPConfig"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_ip_configuration {
      name                 = "myFrontendIPConfig"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  frontend_port {
    name = "myFrontendPort"
    port = 80
  }

  backend_address_pool {
    name = "myBackendAddressPool"
  }

  backend_http_settings {
    name                  = "myBackendHttpSettings"
    cookie_based_affinity = "Enabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "myHttpListener"
    frontend_ip_configuration_name = "myFrontendIPConfig"
    frontend_port_name             = "myFrontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "myRequestRoutingRule"
    rule_type                  = "Basic"
    http_listener_name         = "myHttpListener"
    backend_address_pool_name  = "myBackendAddressPool"
    backend_http_settings_name = "myBackendHttpSettings"
  }
}
