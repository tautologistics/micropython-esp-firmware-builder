#!/bin/bash

docker build -t micropython .
docker create --name micropython micropython
