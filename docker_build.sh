#!/usr/bin/env bash

# Use this script for reproducible builds!
# Any arguments supported by make are supported here.
#   Example: ./docker_build.sh -j TARGET=arm-linux-musleabi all
set -e

docker build -t static-builder .
docker run -it -v "${PWD}/output":"/build/output" --rm static-builder "$@"