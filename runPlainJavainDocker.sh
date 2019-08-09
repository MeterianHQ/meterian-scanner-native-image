#!/bin/bash

set -e
set -u
set -o pipefail

docker run -it                                            \
           --volume $(pwd):/workspace                     \
           --volume $HOME/.meterian:/root/.meterian       \
           --env METERIAN_API_TOKEN=${METERIAN_API_TOKEN} \
           --workdir /workspace                           \
           adoptopenjdk/openjdk8:jdk8u212-b03             \
           /bin/bash