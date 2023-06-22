module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 12.0"

  project_id  = var.project_id
  enable_apis = var.enable_apis

  activate_apis = [
    "compute.googleapis.com",
    "pubsub.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
  disable_services_on_destroy = false
}
