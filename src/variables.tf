variable "workload_name" {
  description = "Name of the workload"
  type        = string
  default     = "vpn"
}

variable "location_short" {
  description = "Short location name"
  type        = string
  default     = "fc"
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "France Central"
}

variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_address_prefix" {
  description = "The address prefix of the subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "vm_private_ip" {
  description = "Static IP address for the VM"
  type        = string
  default     = "10.10.0.4"
}

variable "server_address" {
  description = "WireGuard IP address"
  type        = string
  default     = "10.10.0.5/24"
}

variable "client_address" {
  description = "Client IP address"
  type        = string
  default     = "10.10.0.6/24"
}

variable "client_public_key" {
  description = "Client public key"
  type        = string
}

variable "client_private_key" {
  description = "Client private key"
  type        = string
}

variable "server_public_key" {
  description = "WireGuard public key"
  type        = string
}

variable "server_private_key" {
  description = "WireGuard private key"
  type        = string
}
