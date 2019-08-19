#!/bin/bash

set -e
set -u
set -o pipefail

source common.sh

downloadMavenArchive
MAVEN_TARGET_DIR=/opt
unpackMavenArchive ${MAVEN_TARGET_DIR}

export PATH=${M2_HOME}:${PATH}

update-alternatives --install "/usr/bin/mvn" "mvn" "${MAVEN_TARGET_DIR}/apache-maven-${MAVEN_VERSION}/bin/mvn" 0
update-alternatives --set mvn ${MAVEN_TARGET_DIR}/apache-maven-${MAVEN_VERSION}/bin/mvn

mvn --version