# Meterian scanner native image

Meterian Scanner native-image created using GraalVM native-image builder.

A collection of scripts to download, build and test the meterian scanner native image.

The native image images produced by these may still need some amendments, and we would know from client usage. Everytime it can't find something at runtime, it would throw an error, callstack and a suggestion as to what to do fix it. We use these suggestions and rebuild the image and try again.

**Table of Contents**

- [Requirements](#requirements)
- [Scripts provided](#scripts-provided)
    + [Build meterian client native image](#build-meterian-client-native-image)
        + [Artifacts created from scripts](#artifacts-created-from-scripts)
        + [Dependencies (runtime)](#dependencies-runtime)
        + [Known issue(s)](#known-issues)
    + [Build meterian client native image installer](#build-meterian-client-native-image-installer)
        + [Artifacts created from scripts](#artifacts-created-from-scripts-1)
        + [Dependencies (buildtime)](#dependencies-buildtime)
- [Docker and related scripts provided](#docker-and-related-scripts-provided)
- [CI/CD process](#cicd-process)
- [Usages](#usages)
  - [Build meterian client native image](#build-meterian-client-native-image-1)
  - [Build meterian client native image installer](#build-meterian-client-native-image-installer-1)

## Requirements

- Docker 19.03.1 or higher (Linux or MacOS)
- Maven 3.1.1 or higher
- GraalVM 19.1.1 JDK or higher
- Java 8 JDK (optional, testing purposes)
- libsunec, cacerts for both Linux and MacOS from any JDK 8 or GraalVM
- `JAVA_HOME` setup in the local environment (points to JDK 8 or GraalVM JDK)
- `GRAALVM_HOME` setup in the local environment (points to GraalVM JDK)
- `PATH` setup in the local environment
- `METERIAN_API_TOKEN` setup in the local environment

## Scripts provided

Most if not all the scripts are OS platform aware and will perform actions accordingly. So run them on the respective target platforms to create the respective artifacts for the target platform.

Scripts do not support Windows, unless run inside `git bash` or `cygwin`, although this has not been tested.

All scripts have been written with idempotency in as many cases possible.

`common.sh` has a few functions that are used across all the scripts in the project.

### Build meterian client native image

- `build-native-image/downloadClientJar.sh`: helps download the Jar file from the remote canary (one-off execution)
- `build-native-image/prepareForNativeBuild.sh`: builds the META-INF folder which contains all the necessary native-image related properties needed during building of the image. The native-image tracing agent is passed to the java launcher to trace the jar and reach out to classes and methods in it. Recommend expanding the `runTracerToExtractMetaInf()` function by adding more ways to invoke the jar binary to be able to reach furthest into the code path and captures all classes and methods at build time.
- `build-native-image/buildNativeImage.sh`: builds the image using the META-INF folder created by the above script, and then tests it to check for sanity (basic tests)
- `build-native-image/testNativeImage.sh`: tests the built image for sanity (basic tests) - recommend expanding it

#### Artifacts created from scripts

- `build-native-image/meterian-cli-linux`: native image binary for Linux created from the `meterian-cli.jar` file
- `build-native-image/meterian-cli-macos`: native image binary for MacOS created from the `meterian-cli.jar` file
- `build-native-image/build-linux.logs`, `build-native-image/build-macos.logs`: build logs produced when `build-native-image/buildNativeImage.sh` is run for the respective OS
- `build-native-image/META-INF/native-image`: folder with all the configuration files extracted by the native-image tracing agent needed during build time

#### Dependencies (runtime)

- Maven for both Linux and MacOS
- `libsunec.so` for Linux (although this didn't seem to be needed when running inside a slim docker container running Linux)
- `libsunec.dylib` for MacOS (usually present in the `${JAVA_HOME}/jre/lib/` folder of every JDK/JRE installation of MacOS)
    - this file sould be present in the same directory as where the native image is during execution or should be made to point to it via the `-Djava.library.path=/path/to/jre/lib/folder` (see `build-native-image/testNativeImage.sh` script)
- `cacerts` present in the `${JAVA_HOME}/jre/lib/security/cacerts` folder, if absent, such a folder with the certs should be created in the `${JAVA_HOME}/jre/lib/security/` folder

See [GraalVM clojure project](https://github.com/taylorwood/clojurl), for a good example of the specific dependencies.

#### Known issue(s)

- There is potentially a bug in the native-image tracer (see reported [git issue](https://github.com/oracle/graal/issues/1599)) that overwrites our existing `META-INF/native-image/reflect-config.json` if we re-run the `build-installer/prepareForNativeBuild.sh` script. In case `reflect-config.json` needs updating and this happens, revert the lost changes and merge the new changes into the `reflect-config.json` and commit it - will have to be a semi-manual process till the issue is resolved.

### Build meterian client native image installer

- `build-installer/createPayloadArchiveForInstaller.sh`: create an archive of the installables that we will add to the installer bash script
- `build-installer/addPayloadArchiveToInstallScript.sh`: create the installer bash script with the payload archive attached to it, so the script is executable and unpacks the installables into the right target folder (i.e. into `${HOME}/.meterian`)
- `build-installer/meterian-cli`: bash script to run the meterian client when installed on the target Linux/Macos machine, can be invoked from anywhere as long as it is in the path. It takes care of passing the dependencings to the meterian client native image.
- `build-installer/installNativeImageScript.sh.template`: template bash script that is prepended to the payload by the `build-installer/addPayloadArchiveToInstallScript.sh` script. It has the logic to unpack the payload when installer script is called on target machine.

#### Artifacts created from scripts

- `build-installer/build/install-meterian-cli-linux.sh` and `build-installer/build/ install-meterian-cli-macos.sh` - installer scripts generated after scripts from the previous section are executed for the respective OS platform. **They self-contained and are meant for client distribution.**
- `build-installer/apache-maven-3.6.1` and `build-installer/apache-maven-3.6.1-bin.tar.gz` are created when creating the installer scripts for the respective environment.

#### Dependencies (buildtime)

- `build-native-image/meterian-cli-linux` or `build-native-image/meterian-cli-macos`
- `build-installer/linux-deps/libsunec.so`, `build-installer/linux-deps/cacerts`, `build-installer/macos-deps/libsunec.dylib` and `build-installer/macos-deps/cacerts`: ideal these should not be part of the repo, we should copy them from the `${JAVA_HOME}/jre/lib` and `${JAVA_HOME}/jre/lib/security` folders respectively for each build per OS platform
- `build-installer/installNativeImageScript.sh.template`
- `build-installer/apache-maven-3.6.1-bin.tar.gz`

### Docker and related scripts provided

- `installMaven.sh`: install mvn in an environment where it is absent (in theory should work on most Linux installations). Not meant for MacOS, not tested on it.
- `runPlainJavainDocker.sh`: run a docker container with the Meterian environment variable enabled and local directory mapped/mounted as a volume into it. Traditional JDK (OpenJDK 8) available on path.
- `runGraalVMinDocker.sh`: run a docker container with the Meterian environment variable enabled and local directory mapped/mounted as a volume into it. GraalVM 19.1.1 JDK available on path. Use the script to also build the meterian scanner native image for Linux inside an isolate Linux environment.

Both the `runXxxxx.sh` scripts are used to test the meterian scanner native image in an isolated environment running Traditional or GraalVM JDKs.

## CI/CD process

You will need the ideas in the below scripts to integrate into the CI/CD process:

- `build-native-image/prepareForNativeBuild.sh`
- `build-native-image/buildNativeImage.sh`
- `build-native-image/testNativeImage.sh` (already run by `build-native-image/buildNativeImage.sh`)
- `build-installer/addPayloadArchiveToInstallScript.sh`
- `build-installer/createPayloadArchiveForInstaller.sh`
- `build-installer/installNativeImageScript.sh.template`
- `build-installer/meterian-cli`

## Usages

### Build meterian client native image

#### downloadClientJar.sh

```bash
cd build-native-image
./downloadClientJar.sh
```

Downloads the jar artifact into the `${HOME}/.meterian` folder, if absent, creates the folder.

#### prepareForNativeBuild.sh

```bash
cd build-native-image
./prepareForNativeBuild.sh
```

Will create a `META-INF/native-image` folder containing configuration files (in json format), extracted by the native-image tracing agent.

#### buildNativeImage.sh

```bash
cd build-native-image
./buildNativeImage.sh
```

Expects the `META-INF/native-image` folder containing configuration files (in json format), as it is passed in to the native-image during build time.

By default picks up `$HOME/.meterian/meterian-cli.jar`

```bash
cd build-native-image
./buildNativeImage.sh /path/to/another/jar/file
```

```bash
cd build-native-image
SHOW_STACK_TRACES=true ./buildNativeImage.sh
```

Show stack trace when failures happen during the build process.

```bash
cd build-native-image
./buildNativeImage.sh
```

When running build from inside the docker container or in the Linux environment, in case `JAVA_HOME` is not set.

#### testNativeImage.sh

```
cd build-native-image
./testNativeImage.sh
```

By default picks up `$HOME/.meterian/meterian-cli.jar`

```bash
cd build-native-image
./testNativeImage.sh /path/to/another/jar/file
```

When running inside the docker container or in the Linux environment where `JAVA_HOME` has not been set.

### Build meterian client native image installer

#### createPayloadArchiveForInstaller.sh

```bash
cd build-installer
./createPayloadArchiveForInstaller.sh
```

#### addPayloadArchiveToInstallScript.sh

```bash
cd build-installer
./addPayloadArchiveToInstallScript.sh
```

#### meterian-cli (bash script)

```bash
[ensure path to the script is added to PATH env variable]

cd folder/to/project
meterian-cli
meterian-cli -help
meterian-cli -Dlog.level=INFO
meterian-cli [meterian CLI options]
```

#### meterian-cli-linux (not used by end-user directly)

```bash
meterian-cli-linux --help
meterian-cli-linux -Dlog.level=INFO
```

The above commands work just out of the box, although to scan a project we need the below:

```bash
meterian-cli-macos -Djava.library.path=${JAVA_HOME}/jre/lib           \
                   -Djavax.net.ssl.trustStore="${JAVA_HOME}/jre/lib/security/cacerts" \
                   -Djavax.net.ssl.trustStorePassword=changeit        \
                   [meterian CLI options]
```

#### meterian-cli-macos (not used by end-user directly)

```bash
meterian-cli-macos --help
meterian-cli-macos -Dlog.level=INFO
```

The above commands work just out of the box, although to scan a project we need the below:

```bash
meterian-cli-macos -Djava.library.path=${JAVA_HOME}/jre/lib           \
                   -Djavax.net.ssl.trustStore="${JAVA_HOME}/jre/lib/security/cacerts" \
                   -Djavax.net.ssl.trustStorePassword=changeit        \
                   [meterian CLI options]
```

Passing the `-Djava.library.path=${JAVA_HOME}/jre/lib` is necessary in order for the client to make secure http connection to the meterian site. Initial commit with working version of scripts to produce native image of the meterian scanner

### Docker supporting scripts

#### installMaven.sh

```bash
./installMaven.sh
```

Idempotently downloads, unpacks and installs Maven in an environment, tests the installation.

#### runPlainJavainDocker.sh

```bash
./runPlainJavainDocker.sh
```

Expects the `METERIAN_API_TOKEN` environment variable to be set. Maps the current folder on the host to the `/workspace` folder inside the container.

#### runGraalVMinDocker.sh

```bash
./runGraalVMinDocker.sh
```

Both the `runXxxxx.sh` scripts map the `$HOME/.meterian` folder and the current folder on the host to the `/root/.meterian` and `/workspace` folders inside the container respectively. Also expects the `METERIAN_API_TOKEN` environment variable to be available on the host, which is then made available inside the container.
