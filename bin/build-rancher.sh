#!/bin/bash
set -e

TAG=${TAG:-$(awk '/CATTLE_RANCHER_SERVER_VERSION/{print $3}' Dockerfile)}
REPO=${REPO:-$(awk '/CATTLE_RANCHER_SERVER_IMAGE/{print $3}' Dockerfile)}
IMAGE=${REPO}:${TAG}

git tag -d $TAG 2>/dev/null || true
git tag $TAG
./build-image.sh
git push origin
git push origin $TAG
docker push $IMAGE
