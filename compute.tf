# Network

# Cloud SQL Private Postgres

data "external" "current_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

resource "google_sql_database_instance" "instance" {
  provider = google-beta
  project  = var.project_id
  region   = var.region

  name             = "private-postgres"
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.db_tier
    ip_configuration {
      ipv4_enabled    = false # do not assign public address 
      private_network = data.google_compute_network.network.id

      authorized_networks {
        name  = "on-prem"
        value = "${data.external.current_ip.result.ip}/32"
      }
    }

    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }
  }
}


# Proxy VM

# static ip 
module "address" {
  source     = "terraform-google-modules/address/google"
  version    = "~> 3.1"
  project_id = var.project_id
  region     = var.region
  subnetwork = reverse(split("/",data.google_compute_network.network.subnetworks_self_links[0]))[0]
  names      = ["auth-proxy"]
  addresses  = [var.auth_proxy_ip]
}


resource "google_compute_instance" "default" {
  project      = var.project_id
  name         = "auth-proxy"
  machine_type = var.proxy_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = data.google_compute_network.network.subnetworks_self_links[0]
    network_ip = module.address.addresses[local.i]
    
  }

  metadata_startup_script = <<EOT
#!/bin/sh
apt-get update
sudo apt-get install wget
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy
./cloud_sql_proxy -instances=${google_sql_database_instance.instance.connection_name}:pg-source=tcp:0.0.0.0:5432
  EOT

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "proxy_private_ip" {
  value = google_compute_instance.default.network_interface.0.network_ip
}

output "db_public_ip" {
  value = google_sql_database_instance.instance.public_ip_address
}

locals {
  #nat_map = flatten([ for address in module.address :  address ])
  i = index(module.address["names"],"auth-proxy")

     
}

output "auth_proxy_address" {
  # value = [for a in module.address.addresses : a["name"]=="auth-proxy" ? a["address"] : null ] 
  # value = [for a in module.address : for k,v in a : "${k}=${v}" ] 
  # value = module.address.addresses[local.i]
  value =  reverse(split("/",data.google_compute_network.network.subnetworks_self_links[0]))[0]
}


