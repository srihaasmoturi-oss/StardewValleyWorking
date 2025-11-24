FROM gitpod/workspace-full

USER root

RUN apt-get update -y && \
    apt-get install -y \
        xvfb \
        x11vnc \
        fluxbox \
        websockify \
        novnc \
        curl \
        xterm \
        dbus-x11 \
        mesa-utils \
        libgl1-mesa-dri \
        libgl1-mesa-glx \
        && apt-get clean

USER gitpod
