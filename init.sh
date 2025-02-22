gcloud components install kubectl
gcloud container clusters get-credentials wizthreetier-gke --region us-central1 --project wizthreetier
gcloud auth configure-docker \
    us-central1-docker.pkg.dev
