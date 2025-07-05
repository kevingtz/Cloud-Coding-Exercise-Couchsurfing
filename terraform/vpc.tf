# Enable the Compute Engine API
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# VPC Network
resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

# Subnet
resource "google_compute_subnetwork" "main" {
  name          = "main-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "main-router"
  region  = var.region
  network = google_compute_network.main.id
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "main-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
} 