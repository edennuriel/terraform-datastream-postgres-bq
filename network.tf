
#network and subnet 
module "private_network" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.project_id
  network_name = var.network_name

  subnets = [
    {
      subnet_name   = "${var.network_name}-subnet"
      subnet_ip     = var.main_subnet_cidr
      subnet_region = var.region
    }
  ]
}


# vpc peering via private IP address
data "google_compute_network" "network" {
  provider = google-beta
  project  = var.project_id

  name = var.network_name
}

resource "google_compute_global_address" "sql_cidr" {
  provider = google-beta
  project  = var.project_id

  name          = "sql-private-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.vpc_peering_subnet_start
  prefix_length = 24

  network = data.google_compute_network.network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql_cidr.name]

  depends_on = [module.project-services]
}

resource "google_datastream_private_connection" "default" {
  project               = var.project_id
  display_name          = "Private connection profile"
  location              = var.region
  private_connection_id = "datastream-private"

  vpc_peering_config {
    vpc    = data.google_compute_network.network.id
    subnet = var.datastream_subnet_cidr
  }
}

#reserve IPs
resource "google_compute_address" "external_nat" {
  count        = 3
  name         = "nat-external-ip-${count.index}"
  address_type = "EXTERNAL"
}



module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  region        = var.region
  network       = data.google_compute_network.network.id
  project_id    = var.project_id
  create_router = true
  router        = var.router_name
  nat_ips       = google_compute_address.external_nat[*].self_link
  name          = "${data.google_compute_network.network.name}-${var.router_name}"

}

output "nat-static-ips" {
  value = google_compute_address.external_nat[*].address
}

output "nat-static-links" {
  value = google_compute_address.external_nat[*].self_link
}

