#!/bin/bash

set -e
set -u
set -o pipefail

MAVEN_VERSION="3.6.1"
MAVEN_ARTIFACT="apache-maven-${MAVEN_VERSION}-bin.tar.gz"

echo "~~~ Downloading Apache Maven ${MAVEN_VERSION}"
if [[ ! -e "${MAVEN_ARTIFACT}"  ]]; then
	curl  -O -J -L \
		http://mirror.vorboss.net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_ARTIFACT}
fi

M2_HOME="/opt/apache-maven-${MAVEN_VERSION}"
if [[ ! -e "${M2_HOME}" ]]; then
	mkdir -p ${M2_HOME}
	tar -xvzf ${MAVEN_ARTIFACT} -C /opt/
fi

export PATH=${M2_HOME}:${PATH}

update-alternatives --install "/usr/bin/mvn" "mvn" "/opt/apache-maven-${MAVEN_VERSION}/bin/mvn" 0
update-alternatives --set mvn /opt/apache-maven-${MAVEN_VERSION}/bin/mvn

mvn --version