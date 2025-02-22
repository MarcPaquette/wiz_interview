resource "google_artifact_registry_repository" "containers" {
  location      = "us-central1"
  repository_id = "wizzardcloset"
  format        = "DOCKER"
}
