#!/bin/bash

set -e
set -u
set -o pipefail

docker run -it                                            \
           --volume $(pwd):/workspace                     \
           --volume $HOME/.meterian:/root/.meterian       \
           --env METERIAN_API_TOKEN=${METERIAN_API_TOKEN} \
           --env JAVA_HOME=/opt/java/openjdk              \
           --workdir /workspace                           \
           adoptopenjdk/openjdk8:jdk8u212-b03             \
           /bin/bash