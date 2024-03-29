#!/bin/bash

set -e
set -u
set -o pipefail

source ../common.sh

buildNativeImage() {
	echo ""
	echo "Deleting existing ${IMAGE_NAME}" && rm -f ${IMAGE_NAME}
	echo "~~~~ Building native-image '${IMAGE_NAME}' from ${JARFILE}"
	echo "~~~~ ...this may take a bit of time"
	echo "~~~~ Run 'tail -f build-$(detectOSPlatform).logs' to see current progress"
	native-image ${OPTIONS} -jar ${JARFILE} ${IMAGE_NAME} &> build-$(detectOSPlatform).logs
	echo "~~~~ Finished building native-image '${IMAGE_NAME}' from ${JARFILE}."
}

OPTIONS="${OPTIONS:-} --no-fallback --allow-incomplete-classpath"
OPTIONS="${OPTIONS} --enable-url-protocols=http,https"
OPTIONS="${OPTIONS} -H:ReflectionConfigurationFiles=META-INF/native-image/reflect-config.json"
OPTIONS="${OPTIONS} -H:DynamicProxyConfigurationFiles=META-INF/native-image/proxy-config.json"
OPTIONS="${OPTIONS} -H:ResourceConfigurationFiles=META-INF/native-image/resource-config.json"
OPTIONS="${OPTIONS} -H:JNIConfigurationFiles=META-INF/native-image/jni-config.json"

if [[ "$(detectOSPlatform)" = "linux" ]]; then
	OPTIONS="${OPTIONS} --static ${CLI_ARG_JAVA_LIB_PATH}"

	echo "Using static linking for Linux build of ${IMAGE_NAME}"
else
	echo "Static linking is not support on MacOS atm. Not clear if it is supported on Windows as of yet."
fi 

if [[ "${SHOW_STACK_TRACES:-}" = "true" ]]; then
   OPTIONS="${OPTIONS} -H:+ReportExceptionStackTraces"
fi

setupEnv ${1:-${HOME}/.meterian/meterian-cli.jar}
time buildNativeImage
time ./testNativeImage.sh