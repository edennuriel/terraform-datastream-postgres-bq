resource "google_compute_firewall" "internal" {
  name    = "${var.network_name}-internal"
  network = data.google_compute_network.network.id

  allow {
    protocol = "all"
  }
  source_ranges = [var.main_subnet_cidr]
}

resource "google_compute_firewall" "iap" {
  name    = "${var.network_name}-iap"
  network = data.google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "DataStream-main" {
  name    = "${var.network_name}-peering-main-postgres"
  network = data.google_compute_network.network.id

  allow {
    protocol = "TCP"
    ports    = ["5432"]
  }
  source_ranges = [google_datastream_private_connection.default.vpc_peering_config.0.subnet]
}

