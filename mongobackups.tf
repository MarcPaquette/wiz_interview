# Make bucket public
resource "google_storage_bucket_iam_member" "mongo-s3-public" {
  provider = google
  bucket   = google_storage_bucket.mongo-db-backups-s3-mpp.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

resource "google_storage_bucket_iam_member" "mongo_backup_storage_member" {
  bucket = google_storage_bucket.mongo-db-backups-s3-mpp.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.mongo-user.email}"
}

resource "google_storage_bucket" "mongo-db-backups-s3-mpp" {
  name = "mongodb-backups-s3-mpp-not-taken-heliotrope"
  location      = var.region
  force_destroy = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

}

