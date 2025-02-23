#!/usr/bin/env bash
set -xe

export IMAGE_URL=us-central1-docker.pkg.dev/clgcporg10-154/wizzardcloset/tasky:v1

gcloud auth configure-docker us-central1-docker.pkg.dev


git clone git@github.com:jeffthorne/tasky.git
pushd tasky
# go mod tidy
# go mod vendor 
echo "Marc was here. SH0u+z 2 h4ck3r cr3wz! l33t pwnd." > wizexercise.txt
docker build -t tasky .
docker tag tasky $IMAGE_URL


docker create --name temp_container $IMAGE_URL
docker cp /tmp/wizexercise.txt temp_container:/app/assets/wizexercise.txt
docker commit temp_container $IMAGE_URL
docker container remove temp_container

docker push $IMAGE_URL
popd
rm -rf tasky
