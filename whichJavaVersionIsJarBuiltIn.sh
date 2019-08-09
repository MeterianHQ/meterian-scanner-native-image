#!/bin/bash

set -e
set -u
set -o pipefail

JARFILE=${1:-${HOME}/.meterian/meterian-cli.jar}
unzip -p ${JARFILE} META-INF/MANIFEST.MF