// Creation of the 3 Compute Engine instances for the mongodb cluster.
// The first one will me the leader (where the cluster will be initialized from).
// The 2 other will start as secondary nodes
// Instances will be provisionned on 3 different zones for resiliency purpose.
resource "google_compute_instance" "mongo_node" {
  name         = "mongodb"
  description  = "mongodb vm"

  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image    = "ubuntu-os-cloud/ubuntu-2004-lts"
      size     = 10
    }
  }

  // In this project, the instances are created in a private subnet which is not reachable from internet
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
  }
}
