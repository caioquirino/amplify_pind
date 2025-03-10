# Use Node.js as base image
FROM node:latest

VOLUME /var/lib/containers
VOLUME /home/node/.local/share/containers

RUN echo node:10000:5000 > /etc/subuid; \
    echo node:10000:5000 > /etc/subgid;


# Install required dependencies for Podman
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    sed \
    runc \
    gnupg2 \
    fuse-overlayfs \
    && rm -rf /var/lib/apt/lists/*

# Add Podman repository
RUN echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/ /" > /etc/apt/sources.list.d/podman.list \
    && curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/Release.key | apt-key add -

# Install Podman
RUN apt-get update && apt-get install -y \
    podman \
    && rm -rf /var/lib/apt/lists/*

ADD /containers.conf /etc/containers/containers.conf
ADD /podman-containers.conf /home/podman/.config/containers/containers.conf

RUN mkdir -p /home/node/.local/share/containers && \
    chown node:node -R /home/node && \
    chmod 644 /etc/containers/containers.conf


RUN cp /etc/containers/storage.conf /tmp/storage.conf && sed -e 's|^#mount_program|mount_program|g' \
    -e '/additionalimage.*/a "/var/lib/shared",' \
    -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
    /tmp/storage.conf \
    > /etc/containers/storage.conf

VOLUME /var/lib/containers
VOLUME /home/node/.local/share/containers

RUN mkdir -p /var/lib/shared/overlay-images \
            /var/lib/shared/overlay-layers \
            /var/lib/shared/vfs-images \
            /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock


ENV _CONTAINERS_USERNS_CONFIGURED=""

ENV _CONTAINERS_USERNS_CONFIGURED="" \
    BUILDAH_ISOLATION=chroot

USER node

# Example command to run when container starts
CMD ["podman", "run", "-ti", "docker.io/busybox", "echo", "hello"] 