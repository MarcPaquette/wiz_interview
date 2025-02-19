resource "google_service_account" "default" {
  account_id   = "mongodb-sa"
  display_name = "MongoDB Service Account"
}

resource "google_compute_firewall" "ssh-mongo" {
  name = "mongo-ssh"
  network    = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports = ["22","443","80"]
  }
  target_tags = ["mongodb"]
}

resource "google_compute_instance" "mongo_node" {
  name         = "mongodb"
  description  = "mongodb vm"

  machine_type = "e2-standard-2"
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

  tags=  ["mongodb"]

// Highly Privileged MongoDB VM: Configure the VM in a way that it is granted Admin
// CSP permissions.
 service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
