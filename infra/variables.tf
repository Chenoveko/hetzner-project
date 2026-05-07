variable "hcloud_token" {
  # terraform.tfvars
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "dev"
}

variable "owner" {
  # terraform.tfvars
  description = "Owner of the resources"
  type        = string
  default     = "chenoveko"
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "network_zone" {
  type    = string
  default = "eu-central"
}

variable "ssh_key_name" {
  # terraform.tfvars
  description = "Existing SSH key name in Hetzner Cloud"
  type        = string
}

variable "ssh_allowed_cidrs" {
  # terraform.tfvars
  description = "Your IP(s) allowed to SSH into the NAT gateway"
  type        = list(string)
  default     = []
}

variable "network_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

variable "network_gateway_ip" {
  type    = string
  default = "10.42.0.1"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.42.10.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.42.20.0/24"
}

variable "nat_gateway_private_ip" {
  type    = string
  default = "10.42.20.2"
}

variable "lb_private_ip" {
  type    = string
  default = "10.42.20.10"
}

variable "server_type" {
  type    = string
  default = "cx23"
}

variable "server_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "nat_gateway_server_type" {
  type    = string
  default = "cx23"
}

variable "nat_gateway_image" {
  type    = string
  default = "ubuntu-24.04"
}

##################
#   Management   #
##################

variable "cms_private_ip" {
  type    = string
  default = "10.42.20.11"
}

variable "kubeadmin_private_ip" {
  type    = string
  default = "10.42.20.12"
}

##################
#   Cluster 1    #
##################

variable "controlplanes_clt_1_private_ip" {
  description = "Map of controlplanes clt 1 with their private IPs"
  type = map(object({
    private_ip = string
    location   = optional(string)
  }))
  default = {
    worker1 = { private_ip = "10.42.20.20" }
  }
}

variable "workers_clt_1_private_ip" {
  description = "Map of workers clt 1 with their private IPs"
  type = map(object({
    private_ip = string
    location   = optional(string)
  }))
  default = {
    worker1 = { private_ip = "10.42.20.21" }
  }
}

##################
#   Cluster 2    #
##################

variable "controlplanes_clt_2_private_ip" {
  description = "Map of controlplanes clt 2 with their private IPs"
  type = map(object({
    private_ip = string
    location   = optional(string)
  }))
  default = {
    worker1 = { private_ip = "10.42.20.30" }
  }
}

variable "workers_clt_2_private_ip" {
  description = "Map of workers clt 2 with their private IPs"
  type = map(object({
    private_ip = string
    location   = optional(string)
  }))
  default = {
    worker1 = { private_ip = "10.42.20.31" }
  }
}
