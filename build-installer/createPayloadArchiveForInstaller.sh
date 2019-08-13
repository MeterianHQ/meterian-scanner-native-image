#!/bin/bash

set -e
set -u
set -o pipefail

### Reference: https://www.linuxjournal.com/content/add-binary-payload-your-shell-scripts

source ../common.sh

OSNAME=$(detectOSPlatform)

STATIC_SECURITY_LIB=""
METERIAN_CLIENT=""
if [[ "${OSNAME}" = "linux" ]]; then
	STATIC_SECURITY_LIB="libsunec.so"
elif [[ "${OSNAME}" = "macos" ]]; then
	STATIC_SECURITY_LIB="libsunec.dylib"
fi

echo "~~~~ OS Detected: ${OSNAME}"

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

downloadMavenArchive
unpackMavenArchive ${CURRENT_DIR}

METERIAN_CLIENT="meterian-cli-${OSNAME}"

mkdir -p build
TGZ_ARCHIVE="build/meterian-cli-${OSNAME}.tar.gz"

echo "Deleting existing ${TGZ_ARCHIVE}"
rm -fr ${TGZ_ARCHIVE}

echo "~~~~ Copying meterian-cli-${OSNAME} to current location"
cp ../build-native-image/meterian-cli-${OSNAME} .

echo "~~~~ Copying Java related security deps for ${OSNAME} to current location"
if [[ "${OSNAME}" = "linux" ]]; then
	cp ${JAVA_HOME}/jre/lib/amd64/libsunec.* .
elif [[ "${OSNAME}" = "macos" ]]; then
	cp ${JAVA_HOME}/jre/lib/libsunec.* .
fi
cp ${JAVA_HOME}/jre/lib/security/cacerts .

echo "~~~~ Creating new ${TGZ_ARCHIVE}"
tar cvzf ${TGZ_ARCHIVE}                    \
         ${STATIC_SECURITY_LIB}            \
         ${METERIAN_CLIENT}                \
         cacerts                           \
         meterian-cli                      \
         apache-maven-3.6.1

echo "~~~~ Removing dependencies copied to current location"
rm -f ${STATIC_SECURITY_LIB} cacerts meterian-cli-${OSNAME}

echo "~~~~ Finished creating ${TGZ_ARCHIVE}"