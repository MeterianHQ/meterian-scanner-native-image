# Meterian scanner native image

Meterian Scanner native-image created using GraalVM native-image builder.

A collection of scripts to download, build and test the meterian scanner native image.

The native image images produced by these may still need some amendments, and we would know from client usage. Everytime it can't find something at runtime, it would throw an error, callstack and a suggestion as to what to do fix it. We use these suggestions and rebuild the image and try again.

## Requirements

- Docker 19.03.1 or higher (Linux or MacOS)
- Maven 3.1.1 or higher
- GraalVM 19.1.1 JDK or higher
- Java 8 JDK (optional, testing purposes)
- `JAVA_HOME` setup in the local environment
- `GRAALVM_HOME` setup in the local environment
- `PATH` setup in the local environment
- `METERIAN_API_TOKEN` setup in the local environment

## Scripts provided

- `downloadClientJar.sh`: helps download the Jar file from the remote canary (one-off execution)
- `prepareForNativeBuild.sh`: builds the META-INF folder which contains all the necessary native-image related properties needed during building of the image. The native-image tracing agent is passed to the java launcher to trace the jar and reach out to classes and methods in it. Recommend expanding the `runTracerToExtractMetaInf()` function by adding more ways to invoke the jar binary to be able to reach furthest into the code path and captures all classes and methods at build time.
- `buildNativeImage.sh`: builds the image using the META-INF folder created by the above script, and then tests it to check for sanity (basic tests)
- `testNativeImage.sh`: tests the built image for sanity (basic tests) - recommend expanding it

### Docker and related scripts provide

- `installMaven.sh`: install mvn in an environment where it is absent (in theory should work on most Linux installations). Not meant for MacOS, not tested on it.
- `runPlainJavainDocker.sh`: run a docker container with the Meterian environment variable enabled and local directory mapped/mounted as a volume into it. Traditional JDK (OpenJDK 8) available on path.
- `runGraalVMinDocker.sh`: run a docker container with the Meterian environment variable enabled and local directory mapped/mounted as a volume into it. GraalVM 19.1.1 JDK available on path. Use the script to also build the meterian scanner native image for Linux inside an isolate Linux environment.

Both the `runXxxxx.sh` scripts are used to test the meterian scanner native image in an isolated environment running Traditional or GraalVM JDKs.

## Artifacts created from scripts

- `meterian-cli-linux`: native image binary for Linux created from the `meterian-cli.jar` file
- `meterian-cli-macos`: native image binary for MacOS created from the `meterian-cli.jar` file
- `build.logs`: build logs 
- `META-INF/native-image`: folder with all the configuration files extracted by the native-image tracing agent needed during build time

Comment: the macOS binary is many times bigger than the Linux one.

### Dependencies

- Maven for both Linux and MacOS
- `libsunec.so` for Linux (although this didn't seem to be needed when running inside a slim docker container running Linux)
- `libsunec.dylib` for MacOS (usually present in the `${JAVA_HOME}/jre/lib/` folder of every JDK/JRE installation of MacOS)
    - this file sould be present in the same directory as where the native image is during execution or should be made to point to it via the `-Djava.library.path=/path/to/jre/lib/folder` (see `testNativeImage.sh` script)
- `cacerts` for Java present in the `${JAVA_HOME}/jre/lib/security/cacerts` folder, if absent, such a folder with the certs should be created in the `${JAVA_HOME}/jre/lib/security/` folder

See [GraalVM clojure project](https://github.com/taylorwood/clojurl), for a good example of the specific dependencies.

## CI/CD process

You will need the ideas in the below scripts to integrate into the CI/CD process:

- prepareForNativeBuild.sh
- buildNativeImage.sh 
- testNativeImage.sh (already run by buildNativeImage.sh)

## Usages

### downloadClientJar.sh

```bash
./downloadClientJar.sh
```

Downloads the jar artifact into the `${HOME}/.meterian` folder, if absent, creates the folder.

### prepareForNativeBuild.sh

```bash
./prepareForNativeBuild.sh
```

Will create a `META-INF/native-image` folder containing configuration files (in json format), extracted by the native-image tracing agent.


### buildNativeImage.sh

```bash
./buildNativeImage.sh
```

Expects the `META-INF/native-image` folder containing configuration files (in json format), as it is passed in to the native-image during build time.

By default picks up `$HOME/.meterian/meterian-cli.jar`

```bash
./buildNativeImage.sh /path/to/another/jar/file
```

```bash
SHOW_STACK_TRACES=true ./buildNativeImage.sh
```

Show stack trace when failures happen during the build process.

### testNativeImage.sh

```
./testNativeImage.sh
```

By default picks up `$HOME/.meterian/meterian-cli.jar`

```bash
./testNativeImage.sh /path/to/another/jar/file
```

### installMaven.sh

```bash
./installMaven.sh
```

Idempotently downloads, unpacks and installs Maven in an environment, tests the installation.

### runPlainJavainDocker.sh

```bash
./runPlainJavainDocker.sh
```

Expects the `METERIAN_API_TOKEN` environment variable to be set. Maps the current folder on the host to the `/workspace` folder inside the container.

### runGraalVMinDocker.sh

```bash
./runGraalVMinDocker.sh
```

Both the `runXxxxx.sh` scripts map the `$HOME/.meterian` folder and the current folder on the host to the `/root/.meterian` and `/workspace` folders inside the container respectively. Also expects the `METERIAN_API_TOKEN` environment variable to be available on the host, which is then made available inside the container.

### meterian-cli-linux 

```bash
meterian-cli-linux --help
meterian-cli-linux -Dlog.level=INFO
meterian-cli-linux [meterian CLI options]
```

### meterian-cli-macos

```bash
meterian-cli-macos --help
meterian-cli-macos -Dlog.level=INFO
```

The above commands work just out of the box, although to scan a project we need the below:

```bash
meterian-cli-macos -Djava.library.path=${JAVA_HOME}/jre/lib [meterian CLI options]
```

Passing the `-Djava.library.path=${JAVA_HOME}/jre/lib` is necessary in order for the client to make secure http connection to the meterian site.
>>>>>>> Initial commit with working version of scripts to produce native image of the meterian scanner
