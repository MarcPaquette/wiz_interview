resource "google_storage_bucket" "mongo-db-backups-s3-mpp" {
  name = "mongodb-backups-s3"
  location      = "US"
  force_destroy = true
}
