detectOSPlatform() {
	OSNAME=$(uname)

	if [[ "${OSNAME}" = "Darwin" ]]; then
	 	OSNAME=macos
	elif [[ "${OSNAME}" = "Linux" ]]; then
		OSNAME=linux
	fi

	echo ${OSNAME}
}

MAVEN_VERSION="3.6.1"
MAVEN_ARTIFACT="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
M2_HOME="/opt/apache-maven-${MAVEN_VERSION}"
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

downloadMavenArchive() {
	if [[ ! -e "${CURRENT_DIR}/${MAVEN_ARTIFACT}"  ]]; then
		echo "~~~ Downloading Apache Maven ${MAVEN_VERSION}"
		curl  -O -J -L \
			http://mirror.vorboss.net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_ARTIFACT}
	fi	
}

unpackMavenArchive() {
	TARGET=$1
	M2_HOME="${TARGET}/apache-maven-${MAVEN_VERSION}"
	if [[ ! -e "${M2_HOME}" ]]; then
		echo "~~~ Unpacking Apache Maven ${MAVEN_VERSION} into ${TARGET}"
		mkdir -p ${M2_HOME}
		tar -xvzf ${CURRENT_DIR}/${MAVEN_ARTIFACT} -C ${TARGET}
	fi	
}