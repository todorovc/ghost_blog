provider "azurerm" {
  features {}
}

locals {
  cluster_name = "drs-aks-cluster"
  resource_group_name = "drs-rg"
}

resource "azurerm_resource_group" "this" {
  name = local.resource_group_name
  location = "westeurope"
}

resource "azurerm_kubernetes_cluster" "this" {
  name = local.cluster_name
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  default_node_pool {
    name = "default"
    node_count = var.node_count
    vm_size = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Terraform = "true"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}
