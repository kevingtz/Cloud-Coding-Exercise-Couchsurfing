#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Install Docker and Google Cloud SDK
apt-get update
apt-get install -y docker.io google-cloud-sdk

# Get metadata
REGION=$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google" | cut -d'/' -f4 | sed 's/-[a-z]$//')
DOCKER_IMAGE_URI=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_image_uri -H "Metadata-Flavor: Google")
DB_HOST=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_host -H "Metadata-Flavor: Google")
DB_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_user -H "Metadata-Flavor: Google")
DB_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_password -H "Metadata-Flavor: Google")
DB_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_name -H "Metadata-Flavor: Google")

# Authenticate Docker to Artifact Registry
gcloud auth configure-docker "${REGION}-docker.pkg.dev"

# Pull and run the Docker container
docker pull "${DOCKER_IMAGE_URI}"

docker run -d -p 80:5000 \
  --env "DB_HOST=${DB_HOST}" \
  --env "DB_USER=${DB_USER}" \
  --env "DB_PASSWORD=${DB_PASSWORD}" \
  --env "DB_NAME=${DB_NAME}" \
  --name app_container "${DOCKER_IMAGE_URI}" 