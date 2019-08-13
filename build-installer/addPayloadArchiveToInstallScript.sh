#!/bin/bash

set -e
set -u
set -o pipefail

### Reference: https://www.linuxjournal.com/content/add-binary-payload-your-shell-scripts

source ../common.sh

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p build

OSNAME=$(detectOSPlatform)
TARGET_PAYLOAD_FILE="build/meterian-cli-${OSNAME}.tar.gz"
TARGET_SCRIPT="build/install-meterian-cli-${OSNAME}.sh"

echo "~~~ Deleting existing ${TARGET_SCRIPT}"
rm -f ${TARGET_SCRIPT}

echo "~~~ Adding install bash script to install script ${TARGET_SCRIPT}"
cat installNativeImageScript.sh.template >${TARGET_SCRIPT}

echo "~~~ Adding payload to install script to ${TARGET_SCRIPT}"
echo "PAYLOAD:" >> ${TARGET_SCRIPT}
cat ${TARGET_PAYLOAD_FILE} >>${TARGET_SCRIPT}

echo "~~~ Making ${TARGET_SCRIPT} executable"
chmod +x ${TARGET_SCRIPT}

echo "~~~ Removing payload ${TARGET_PAYLOAD_FILE} archive"
rm -f ${TARGET_PAYLOAD_FILE}

echo "~~~ Finished creating ${TARGET_SCRIPT}"
cd ${SCRIPT_CURRENT_DIR}