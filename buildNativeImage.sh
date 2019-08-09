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

buildNativeImage() {
	echo ""
	echo "Deleting existing ${IMAGE_NAME}" && rm -f ${IMAGE_NAME}
	echo "~~~~ Building native-image '${IMAGE_NAME}' from ${JARFILE}"
	echo "~~~~ ...this may take a bit of time"
	echo "~~~~ Run 'tail -f build-$(detectOSPlatform).logs' to see current progress"
	native-image ${OPTIONS} -jar ${JARFILE} ${IMAGE_NAME} &> build-$(detectOSPlatform).logs
	echo "~~~~ Finished building native-image '${IMAGE_NAME}' from ${JARFILE}."
}

JARFILE=${1:-${HOME}/.meterian/meterian-cli.jar}
IMAGE_NAME=$(basename ${JARFILE%.*})-$(detectOSPlatform)

OPTIONS="${OPTIONS:-} --no-fallback --allow-incomplete-classpath"
OPTIONS="${OPTIONS} --enable-url-protocols=http,https"
OPTIONS="${OPTIONS} -H:ReflectionConfigurationFiles=META-INF/native-image/reflect-config.json"
OPTIONS="${OPTIONS} -H:DynamicProxyConfigurationFiles=META-INF/native-image/proxy-config.json"
OPTIONS="${OPTIONS} -H:ResourceConfigurationFiles=META-INF/native-image/resource-config.json"
OPTIONS="${OPTIONS} -H:JNIConfigurationFiles=META-INF/native-image/jni-config.json"

if [[ "${SHOW_STACK_TRACES:-}" = "true" ]]; then
   OPTIONS="${OPTIONS} -H:+ReportExceptionStackTraces"
fi

time buildNativeImage
time ./testNativeImage.sh