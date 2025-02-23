#!/usr/bin/env bash
set -xe

gcloud components install kubectl
gcloud container clusters get-credentials clgcporg10-154-gke --region us-central1 --project clgcporg10-154
gcloud auth configure-docker us-central1-docker.pkg.dev
