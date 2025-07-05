# Required for private Cloud SQL connection
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}

# Enable the SQL Admin API
resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

# Private VPC connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "main-instance"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }
  }

  deletion_protection = false

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.sqladmin
  ]
}

resource "google_sql_database" "database" {
  name     = "couchsurfing-db"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "users" {
  name     = "couchsurfing-user"
  instance = google_sql_database_instance.main.name
  password = var.db_password
} 