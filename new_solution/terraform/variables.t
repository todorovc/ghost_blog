variable "node_count" {
  description = "The number of nodes in the AKS cluster"
  default = 3
}

variable "vm_size" {
  description = "The VM size for the AKS cluster nodes"
  default = "Standard_D2_v2"
}
