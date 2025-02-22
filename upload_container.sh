#!/usr/bin/env bash
set -xe

git clone git@github.com:jeffthorne/tasky.git
pushd tasky
go mod tidy
go mod vendor 
docker build -t tasky .
docker tag tasky us-central1-docker.pkg.dev/wizthreetier/wizzardcloset/tasky:v1
gcloud auth configure-docker us-central1-docker.pkg.dev
docker push us-central1-docker.pkg.dev/wizthreetier/wizzardcloset/tasky:v1
popd
rm -rf tasky
