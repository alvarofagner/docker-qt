# syntax = docker/dockerfile:1.4
FROM ubuntu:22.04 AS base

# The image version
ARG VERSION=0.0.1
# QT_FOLDER_TYPE can be either 'archive' or 'official_releases'. Check where the desired version is located.
ARG QT_FOLDER_TYPE=archive
# The QtCreator version
ARG QT_FULL_VERSION=5.14.2
# NDK Version
ARG NDK_VERSION=20.1.5948944

ARG QT_USERNAME
ARG QT_PASSWORD

# Username and password for Qt are required
RUN \
    if [ -z ${QT_USERNAME+x} ]; then echo "Qt Username must be set"; exit 1; else echo "Qt Username is set to '$QT_USERNAME'"; fi && \
    if [ -z ${QT_PASSWORD+x} ]; then echo "Qt Password must be set"; exit 1; else echo "Qt Password is set"; fi

ENV QT_CI_LOGIN=$QT_USERNAME
ENV QT_CI_PASSWORD=$QT_PASSWORD
ENV QT_INSTALLATION_FOLDER=/opt/Qt
ENV QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb

LABEL name="qt" \
      description="Image for Qt $QT_FULL_VERSION" \
      version=$QT_FULL_VERSION-$VERSION

# Copy installer automation script
COPY qt-creator-installer-noninteractive.qs /tmp/

# Dependencies layer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --assume-yes dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
    build-essential \
    curl \
    crudini \
    libclang1 \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    openjdk-8-jdk \
    openssh-client \
    xdg-utils

# Download and run installer
RUN export QT_COMPONENT_VERSION=$(echo $QT_FULL_VERSION | sed 's/\.//g') && \
    QT_URL=https://download.qt.io && \
    QT_MINOR_VERSION=$(echo $QT_FULL_VERSION | cut -d. -f1-2) && \
    QT_INSTALLER_NAME=qt-opensource-linux-x64-$QT_FULL_VERSION.run && \
    QT_DOWNLOAD_URL=$QT_URL/$QT_FOLDER_TYPE/qt/$QT_MINOR_VERSION/$QT_FULL_VERSION/$QT_INSTALLER_NAME && \
    echo "Downloading Qt installer $QT_FULL_VERSION $QT_DOWNLOAD_URL" && \
    curl -L $QT_DOWNLOAD_URL -o /tmp/$QT_INSTALLER_NAME && \
    chmod +x /tmp/$QT_INSTALLER_NAME && \
    echo "Starting install" && \
    QT_QPA_PLATFORM=minimal /tmp/$QT_INSTALLER_NAME --verbose --script /tmp/qt-creator-installer-noninteractive.qs && \
    echo "Cleanup" && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV QT_CI_LOGIN=
ENV QT_CI_PASSWORD=

# Run the image as non-root user
ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # Add sudo support
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# Prepare SDK
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux
ENV ANDROID_NDK_ROOT /opt/android-sdk-linux/ndk/${NDK_VERSION}

COPY --link --from=androidsdk/android-31:latest --chown=$USERNAME:$USERNAME /opt/android-sdk-linux /opt/android-sdk-linux

ENV PATH=${ANDROID_HOME}/bin:${ANDROID_HOME}/tools/bin:$PATH

# Install NDK
RUN sdkmanager --install "ndk;${NDK_VERSION}"

# Automatically update NDK and SDK configurations in QtCreator
ENV QT_CREATOR_CONFIG_FOLDER /home/${USERNAME}/.config/QtProject
COPY --chown=$USERNAME:$USERNAME config/QtCreator.ini $QT_CREATOR_CONFIG_FOLDER/
RUN crudini --set $QT_CREATOR_CONFIG_FOLDER/QtCreator.ini AndroidConfigurations NDKLocation ${ANDROID_NDK_ROOT} \
    && crudini --set $QT_CREATOR_CONFIG_FOLDER/QtCreator.ini AndroidConfigurations SDKLocation ${ANDROID_SDK}

CMD ["/opt/Qt/Tools/QtCreator/bin/qtcreator"]
