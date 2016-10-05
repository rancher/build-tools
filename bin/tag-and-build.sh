#!/bin/bash
set -e

export TAG=$1
export CROSS=1

git tag -d $TAG 2>/dev/null || true
echo Tagging $TAG
git tag $TAG
git reset --hard HEAD
git clean -dxf

if [ -e Makefile ]; then
    make release
elif [ -e Dockerfile.dapper ]; then
    dapper release
elif [ -e Dockerfile ]; then
    release
else
    ./build.sh
fi

echo You need to push the tag
echo -e "\t" git push origin $TAG

if [ -e dist/images ]; then
    for i in $(<dist/images); do
        echo -e "\t" docker push $i
    done
fi
