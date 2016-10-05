#!/bin/bash
set -e

declare -A PIDS

export TAG=$1
export CROSS=1
export DOCKER_API_VERSION=1.22

git tag -d $TAG 2>/dev/null || true
echo Tagging $TAG
git tag $TAG

build()
{
    DIR=build/release/${1,,}
    rm -rf $DIR
    mkdir -p $DIR
    cp -rf .git $DIR
    cd $DIR
    git checkout $TAG >/dev/null 2>&1
    git reset --hard HEAD
    git clean -dxf
    export DOCKER_HOST=${!2}
    echo $DOCKER_HOST
    docker version
    make release
}

rm -rf build/release
mkdir -p build/release

for i in AMD64 ARM ARM64; do
    echo Starting build $i
    build $i DOCKER_${i}_HOST >build/release/${i}.log 2>&1 &
    PIDS[$i]=$!
done

FAILED=
for i in ${!PIDS[@]}; do
    echo Waiting on build $i
    if ! wait ${PIDS[$i]}; then
        FAILED="$FAILED $i"
    fi
done

if [ -n "$FAILED" ]; then
    echo FAILED${FAILED}
    exit 1
fi

echo git push origin $TAG
echo export DOCKER_API_VERSION=1.22

for i in ${!PIDS[@]}; do
    DIR=build/release/${i,,}
    if [ -e $DIR/dist/images ]; then
        for image in $(<$DIR/dist/images); do
            h=DOCKER_${i}_HOST
            echo docker -H ${!h} push $image
        done
    fi
done
