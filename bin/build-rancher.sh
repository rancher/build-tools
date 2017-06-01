#!/bin/bash
set -e

TAG=${TAG:-$(awk '/ENV CATTLE_RANCHER_SERVER_VERSION/{print $3}' Dockerfile)}
REPO=${REPO:-$(awk '/ENV CATTLE_RANCHER_SERVER_IMAGE/{print $3}' Dockerfile)}
IMAGE=${REPO}:${TAG}

git tag -d $TAG || true
git tag $TAG
./build-image.sh
git push origin
git push origin $TAG
docker push $IMAGE
