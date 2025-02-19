# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "mongodb_host"  {
  value = google_compute_instance.mongo_node.name
  description = "mongodb's name"
}

output "mongodb_zone"  {
  value = google_compute_instance.mongo_node.zone
  description = "mongodb's name"
}


output "s3_bucket"  {
  value = google_storage_bucket.mongo-db-backups-s3-mpp.url
  description = "MongDB's backups"
}
