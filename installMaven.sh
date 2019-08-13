#!/bin/bash

set -e
set -u
set -o pipefail

source common.sh

downloadMavenArchive
unpackMavenArchive /opt/

export PATH=${M2_HOME}:${PATH}

update-alternatives --install "/usr/bin/mvn" "mvn" "/opt/apache-maven-${MAVEN_VERSION}/bin/mvn" 0
update-alternatives --set mvn /opt/apache-maven-${MAVEN_VERSION}/bin/mvn

mvn --version