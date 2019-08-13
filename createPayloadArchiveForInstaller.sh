#!/bin/bash

set -e
set -u
set -o pipefail

### Reference: https://www.linuxjournal.com/content/add-binary-payload-your-shell-scripts

source common.sh

OSNAME=$(detectOSPlatform)

STATIC_SECURITY_LIB=""
METERIAN_CLIENT=""
if [[ "${OSNAME}" = "linux" ]]; then
	STATIC_SECURITY_LIB="libsunec.so"
elif [[ "${OSNAME}" = "macos" ]]; then
	STATIC_SECURITY_LIB="libsunec.dylib"
fi

echo "~~~~ OS Detected: ${OSNAME}"

downloadMavenArchive
unpackMavenArchive

METERIAN_CLIENT="meterian-cli-${OSNAME}"

mkdir -p build
TGZ_ARCHIVE="build/meterian-cli-${OSNAME}.tar.gz"

echo "Deleting existing ${TGZ_ARCHIVE}"
rm -fr ${TGZ_ARCHIVE}

echo "~~~~ Copying security deps from ${OSNAME}-deps to current location"
cp ${OSNAME}-deps/* .

echo "~~~~ Creating new ${TGZ_ARCHIVE}"
tar cvzf ${TGZ_ARCHIVE}              \
         ${STATIC_SECURITY_LIB}      \
         ${METERIAN_CLIENT}          \
         cacerts                     \
         meterian-cli                \
         apache-maven-3.6.1
echo "~~~~ Finished creating ${TGZ_ARCHIVE}"

echo "~~~~ Removing security dependencies copied to current location"
rm -f ${STATIC_SECURITY_LIB} cacerts