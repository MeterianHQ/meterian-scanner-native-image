#!/bin/bash

set -e
set -u
set -o pipefail

source ../common.sh

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
	     --dump=dependencies      \
	     --report-json=${PROJECT_FOLDER}/report.json && true
	cd ${CURRENT_DIR}
	echo "~~~~ Finished testing built binary on autofix-sample-maven-upgrade"
}

runRealMoreOptions() {
	echo ""
	echo "~~~~ Testing built binary on autofix-sample-maven-upgrade (with more options)"
	CURRENT_DIR=$(pwd)
	echo ""
	PROJECT_FOLDER=$(cloneProject ${CURRENT_DIR})
	cd ${PROJECT_FOLDER}
	${CURRENT_DIR}/${IMAGE_NAME}  \
	     --start-only             \
	     ${CLI_ARG_JAVA_LIB_PATH}

	${CURRENT_DIR}/${IMAGE_NAME}  \
	     ${CLI_ARG_JAVA_LIB_PATH} \
	     --clean                  \
	     -Dlog.level=INFO         \
	     --min-security=90        \
	     --min-stability=90       \
	     --min-licensing=90       \
	     --dump=dependencies      \
	     --report-json=${PROJECT_FOLDER}/report.json && true
	cd ${CURRENT_DIR}
	echo "~~~~ Finished testing built binary on autofix-sample-maven-upgrade"	
}

setupEnv ${1:-${HOME}/.meterian/meterian-cli.jar}
runBasic
runReal
runRealMoreOptions