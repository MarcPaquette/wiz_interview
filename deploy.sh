#!/usr/bin/env bash
set -xe

# Preflight checks
terraform init
terraform validate

# Deploy Mongo VM & network
terraform apply \
    -target=google_service_account.mongo-user \
    -target=google_compute_firewall.ssh-mongo \
    -target=google_compute_instance.mongo_node \
    -target=google_compute_network.vpc \
    -target=google_compute_subnetwork.subnet \
    -target=google_compute_router.router \
    -target=google_compute_router_nat.nat

# Install Mongo
sleep 20 #give VM time to start
./install_mongo.sh

# Deploy GCP Artifact storage
terraform apply -target=google_artifact_registry_repository.containers

# Deploy Docker Image
./upload_container.sh


# Deploy everything
terraform apply -auto-approve
