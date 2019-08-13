# Meterian scanner native image

Meterian Scanner native-image created using GraalVM native-image builder.

A collection of scripts to download, build and test the meterian scanner native image.

The native image images produced by these may still need some amendments, and we would know from client usage. Everytime it can't find something at runtime, it would throw an error, callstack and a suggestion as to what to do fix it. We use these suggestions and rebuild the image and try again.

**Table of Contents**

- [Requirements](#requirements)
- [Workflow](#workflow)
  - [Build meterian client native-image](#build-meterian-client-native-image)
  - [Build meterian client native-image installer](#build-meterian-client-native-image-installer)

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

## Workflow

### Installations & setup

- Install Docker, Maven, GraalVM and Java 8 JDK
- Set `GRAALVM_HOME`
- Set the `JAVA_HOME` to point to `GRAALVM_HOME`
- Set PATH to point to `JAVA_HOME/bin`
- Set Maven related environment variables and PATH
- Set `METERIAN_API_TOKEN`

### Build meterian client native-image

- Ensure current `JAVA_HOME` is pointing to `GRAALVM_HOME` and also mentioned in the `PATH`
- Enter the `build-native-image` folder
- Download (using `downloadClientJar.sh`) or copy the `meterian-cli.jar` into this folder
- Run `prepareForNativeBuild.sh` (can be skipped as we already have a populated `META-INF` folder)
- Ensure that the `${JAVA_HOME}/jre/lib/libsunec.{so|dylib}` and `${JAVA_HOME}/jre/lib/security/cacerts` exist for the JDK selected
- Run `buildNativeImage.sh` (this will run the `testNativeImage.sh`)
- This will produce the `meterian-cli-{linux|macos}` artifacts in the current folder

### Build meterian client native-image installer

- Enter the `build-installer` folder
- Run `createPayloadArchiveForInstaller.sh`
- Run `addPayloadArchiveToInstallScript.sh`
- This will create the `install-meterian-cli-{linux|macos}.sh` in the `build`sub-folder (which is self-contained and distributable to end-users)

See [Details section](README-details.md) to find out in detail about the scripts, dependencies and artifacts created.