#!/bin/bash

function check () {
  if [[ ! $1 ]]; then
    echo "No ARCH param provided!";
    exit 1
  fi
}

function run () {
  arch=$1
  shift
  echo ARCH: $arch
  echo ARGS: $*

  docker run \
    --rm \
    -it \
    \
    -v $(pwd)/../micropython:/build/micropython \
    \
    -v $(pwd)/modules-$arch:/build/micropython/ports/$arch/modules \
    -v $(pwd)/../../app/extlib:/build/micropython/ports/$arch/modules/extlib \
    -v $(pwd)/../../app/fonts:/build/micropython/ports/$arch/modules/fonts \
    -v $(pwd)/../../app/utils:/build/micropython/ports/$arch/modules/utils \
    \
    --user root \
    --workdir /build/micropython/ports/$arch \
    micropython  \
    $*
}
