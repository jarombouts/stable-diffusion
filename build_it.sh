#!/bin/bash

NAME=${NAME:=stable-diffusion/$(basename $(pwd))}
TAG=${TAG:=latest}
DOCKERFILE=${DOCKERFILE:="."}

set -euo pipefail

function build() {
  echo "*** Building container $NAME:$TAG using dockerfile $DOCKERFILE"

  # test if uname -m is arm64 or aarch64
  if [ "$(uname -m)" == "arm64" ] || [ "$(uname -m)" == "aarch64" ]; then
    echo "??? You seem to have an M1 macbook; trying to build amd64 image using dockerx"
    docker buildx build -t $NAME $DOCKERFILE \
      # --build-arg PIP_EXTRA_INDEX_URL="$PIP_EXTRA_INDEX_URL" \
      --platform linux/amd64 \
      --load # buildx needs this to actually save the result to 'docker images'
  else
    docker build -t $NAME $DOCKERFILE \
    #  --build-arg PIP_EXTRA_INDEX_URL="$PIP_EXTRA_INDEX_URL"
  fi
}

function tag() {
  echo "*** Tagging container $NAME -> $NAME:$TAG and $NAME:latest"
  docker tag $NAME $NAME:$TAG   #$REGISTRY/$NAME:$TAG
  docker tag $NAME $NAME:latest #$REGISTRY/$NAME:latest
}

build
tag

