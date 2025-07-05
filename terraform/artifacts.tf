# Enable the Artifact Registry API
resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = var.artifact_repo_name
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
} 