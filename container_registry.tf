resource "google_artifact_registry_repository" "containers" {
  location      = "us-central1"
  repository_id = "wizzardcloset"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "gke_pull_access" {
  location   = google_artifact_registry_repository.containers.location
  repository = google_artifact_registry_repository.containers.name
  role       = "roles/artifactregistry.reader"
  member      = "allUsers"
}
