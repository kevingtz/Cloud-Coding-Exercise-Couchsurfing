# Instance Template
resource "google_compute_instance_template" "main" {
  name_prefix  = "main-template-"
  machine_type = "f1-micro"
  region       = var.region
  tags         = ["http-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id
    access_config {} # Ephemeral public IP for pulling from git, etc.
  }

  metadata = {
    startup-script   = file("${path.module}/startup.sh")
    docker_image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.docker_image_name}"
    db_host          = google_sql_database_instance.main.private_ip_address
    db_user          = google_sql_user.users.name
    db_password      = var.db_password
    db_name          = google_sql_database.database.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_sql_database_instance.main]
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "main" {
  name   = "main-mig"
  region = var.region
  
  version {
    instance_template = google_compute_instance_template.main.id
  }

  base_instance_name = "app-vm"

  named_port {
    name = "http"
    port = 80
  }
}

# Autoscaler
resource "google_compute_region_autoscaler" "main" {
  name   = "main-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.main.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}

# Health Check
resource "google_compute_health_check" "http" {
  name                = "http-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }

  depends_on = [google_project_service.compute]
}

# Backend Service
resource "google_compute_backend_service" "main" {
  name        = "main-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  
  backend {
    group = google_compute_region_instance_group_manager.main.instance_group
  }
  
  health_checks = [google_compute_health_check.http.id]
}

# URL Map
resource "google_compute_url_map" "main" {
  name            = "main-url-map"
  default_service = google_compute_backend_service.main.id
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "main" {
  name    = "main-target-proxy"
  url_map = google_compute_url_map.main.id
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "main" {
  name       = "main-forwarding-rule"
  target     = google_compute_target_http_proxy.main.id
  port_range = "80"
} 