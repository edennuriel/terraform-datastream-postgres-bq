variable "auth_proxy_ip" {
  type    = string
  default = "192.168.100.2"
}

variable "router_name" {
  type    = string
  default = "demo"
}

variable "enable_apis" {
  type    = string
  default = "true"
}

variable "project_id" {
  type    = string
  default = "ednmlai"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "proxy_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "network_name" {
  type    = string
  default = "private-net"
}

variable "main_subnet_cidr" {
  type    = string
  default = "192.168.100.0/24"
}

variable "datastream_subnet_cidr" {
  type    = string
  default = "192.168.250.0/29"
}

variable "vpc_peering_subnet_start" {
  type    = string
  default = "192.168.200.0"
}
