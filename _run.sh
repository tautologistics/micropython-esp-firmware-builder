#!/bin/bash

function check () {
  if [[ ! $1 ]]; then
    echo "No ARCH param provided!";
    echo "Usage: $0 <esp32|esp8266>"
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
    -v $(pwd)/../micropython-app/mylib:/build/micropython/ports/$arch/modules/mylib \
    --user root \
    --workdir /build/micropython/ports/$arch \
    micropython  \
    $*
}
