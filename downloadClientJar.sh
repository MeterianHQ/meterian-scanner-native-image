#!/bin/bash

set -e
set -u
set -o pipefail

curl  -O -J \
         -L  https://www.meterian.com/downloads/meterian-cli-canary.jar

mkdir -p ${HOME}/.meterian
mv meterian-cli-canary.jar ${HOME}/.meterian/meterian-cli.jar