#!/usr/bin/env bash
set -xe

MONGODB_HOST=$(terraform output -raw mongodb_host) 
MONGO_DB_ZONE=$(terraform output -raw mongodb_zone)
gcloud compute ssh "$MONGODB_HOST" \
   --zone "$MONGO_DB_ZONE" \
   --command "curl https://raw.githubusercontent.com/MarcPaquette/wiz_interview/refs/heads/main/mongo_deploy.sh | bash" 
