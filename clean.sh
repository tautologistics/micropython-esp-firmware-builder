#!/bin/sh

docker run \
  --rm \
  -it \
  \
  -v $(pwd)/../micropython:/build/micropython \
  \
  -v $(pwd)/modules-$1:/build/micropython/ports/$1/modules \
  -v $(pwd)/../../app/extlib:/build/micropython/ports/$1/modules/extlib \
  -v $(pwd)/../../app/fonts:/build/micropython/ports/$1/modules/fonts \
  -v $(pwd)/../../app/utils:/build/micropython/ports/$1/modules/utils \
  \
  --user root \
  --workdir /build/micropython/ports/$1 \
  micropython  \
  make clean
