#!/bin/bash

set -e
set -u
set -o pipefail

rm -f meterian-scanner-native-image-scripts.tgz

tar --exclude='./whichJavaVersionIsJarBuiltIn.sh'   \
    --exclude='./makeArchiveForBruno.sh'            \
    -zcvf meterian-scanner-native-image-scripts.tgz \
    *.sh README.md meterian-cli-* META-INF