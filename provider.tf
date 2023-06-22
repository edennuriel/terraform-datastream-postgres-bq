# An example of how to connect two GCE networks with a VPN
provider "google-beta" {
  project = var.project_id
  region  = var.region
}
provider "google" {
  project = var.project_id
  region  = var.region
}
