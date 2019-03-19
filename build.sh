#!/bin/bash

. "_run.sh"
check $1
run $1 make
docker cp --follow-link micropython:/build/firmware-$1.bin .
