variable "project_id" {
  description = "The project ID to host the resources in"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region to host the resources in"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to host the resources in"
  type        = string
  default     = "us-central1-a"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "artifact_repo_name" {
  description = "The name for the Artifact Registry repository"
  type        = string
  default     = "app-repo"
}

variable "docker_image_name" {
  description = "The name of the docker image in Artifact Registry (e.g., 'my-app:latest')"
  type        = string
  default     = "app:latest"
} 