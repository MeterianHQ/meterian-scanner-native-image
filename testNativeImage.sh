#!/bin/bash

set -e
set -u
set -o pipefail

detectOSPlatform() {
	OSNAME=$(uname)

	if [[ "${OSNAME}" = "Darwin" ]]; then
	 	OSNAME=macos
	elif [[ "${OSNAME}" = "Linux" ]]; then
		OSNAME=linux
	fi

	echo ${OSNAME}
}

JAVA_LIB_PATH="" # not needed for Linux, only for MacOS
CLI_ARG_JAVA_LIB_PATH="" # not needed for Linux, only for MacOS
JARFILE=""
IMAGE_NAME=""
setupEnv() {
 	if [[ "$(detectOSPlatform)" = "macos" ]]; then
 		export JAVA_LIB_PATH="${GRAALVM_HOME}/jre/lib"
 	fi
 	CLI_ARG_JAVA_LIB_PATH="-Djava.library.path=${JAVA_LIB_PATH}"

 	JARFILE=$1
	IMAGE_NAME=$(basename ${JARFILE%.*})-$(detectOSPlatform)
}

runBasic() {
	echo ""
	echo "~~~~ Testing built binary ${IMAGE_NAME}"
	./${IMAGE_NAME} -Dlog.level=INFO ${CLI_ARG_JAVA_LIB_PATH} --help
	./${IMAGE_NAME} -Dlog.level=INFO ${CLI_ARG_JAVA_LIB_PATH} || true
	echo "~~~~ Finished testing built binary ${IMAGE_NAME}"
}

cloneProject() {
	CURRENT_DIR=$1
	if [[ ! -d "autofix-sample-maven-upgrade" ]]; then
		git clone git@github.com:MeterianHQ/autofix-sample-maven-upgrade.git
	fi
	echo "${CURRENT_DIR}/autofix-sample-maven-upgrade"
}

runReal() {
	echo ""
	echo "~~~~ Testing built binary on autofix-sample-maven-upgrade"
	CURRENT_DIR=$(pwd)
	echo ""
	PROJECT_FOLDER=$(cloneProject ${CURRENT_DIR})
	cd ${PROJECT_FOLDER}
	${CURRENT_DIR}/${IMAGE_NAME}  \
	     ${CLI_ARG_JAVA_LIB_PATH} \
	     -Dlog.level=INFO         \
	     --dump=dependencies.     \
	     --report-json=${PROJECT_FOLDER}/report.json && true
	cd ${CURRENT_DIR}
	echo "~~~~ Finished testing built binary on autofix-sample-maven-upgrade"
}

setupEnv ${1:-${HOME}/.meterian/meterian-cli.jar}
runBasic
runReal