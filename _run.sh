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
    -v $(pwd)/../../app/extlib:/build/micropython/ports/$arch/modules/extlib \
    -v $(pwd)/../../app/fonts:/build/micropython/ports/$arch/modules/fonts \
    -v $(pwd)/../../app/utils:/build/micropython/ports/$arch/modules/utils \
    -v $(pwd)/../micropython/ports/esp8266/esp8266.ld:/build/micropython/ports/esp8266/esp8266.ld \
    --user root \
    --workdir /build/micropython/ports/$arch \
    micropython  \
    $*
}
