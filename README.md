# Qt Docker Image

This docker file downloads and installs Qt non-commercial components and QtCreator on the image. So one can run this container with QtCreator with no need to prepare its environment for Qt development. It also prepares the SDK and NDK in order to build for Android as well for Desktop.

## Requirements

* Docker
* A Qt user login is required for the Qt installation. Create a user [here](https://www.qt.io/) if you do not have one yet.

## Instructions

In order to build the image, you need to specify which version of Qt you want to install. Check the available versions in [official releases](https://download.qt.io/official_releases/qtcreator/) or [archived](https://download.qt.io/archive/qtcreator/).

Depending if it is official release or archived, one needs to specify it passing QTC_FOLDER_TYPE parameter to the docker command.

An example command for building the image would be:

```bash
export MY_QT_CI_LOGIN="Your Qt login email"
export MY_QT_CI_PASSWORD="Your Qt password"

docker build \
    --progress=plain \
    --build-arg QT_FOLDER_TYPE="archive" \
    --build-arg QT_FULL_VERSION="5.14.2" \
    --build-arg QT_USERNAME=$MY_QT_CI_LOGIN \
    --build-arg QT_PASSWORD=$MY_QT_CI_PASSWORD \
    . -t my-image-qt:5.14.2
```

## Running and executing locally

Allow X server connection

```bash
xhost +local:*
```

Run the container. This will automatically launch QtCreator from it.

```bash
docker run \
    --rm \
    --name qt001 \
    --env="DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    my-image-qt:5.14.2
```

**TIP:** You can also mount another volume to be the home folder for your source code. 

## Pushing image to DockerHub

```bash
docker login
docker push my-image-qt:[tagname]
```
