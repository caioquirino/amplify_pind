# Use Node.js as base image with build argument
ARG NODE_VERSION=20
FROM --platform=$TARGETPLATFORM node:${NODE_VERSION}

VOLUME /var/lib/containers
VOLUME /home/node/.local/share/containers


# Install required dependencies for Podman
RUN apt-get update && apt-get install -y \
  software-properties-common \
  curl \
  sed \
  runc \
  gnupg2 \
  fuse-overlayfs \
  uidmap \
  sudo \
  && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2 ./aws

# Add Podman repository based on architecture
RUN case $(uname -m) in \
  x86_64) ARCH="amd64" ;; \
  aarch64) ARCH="arm64" ;; \
  *) echo "Unsupported architecture" && exit 1 ;; \
  esac && \
  echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_12/ /" > /etc/apt/sources.list.d/podman.list && \
  curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_12/Release.key | apt-key add -

# Install Podman and Docker compatibility layer
RUN apt-get update && apt-get install -y \
  podman \
  podman-docker \
  && rm -rf /var/lib/apt/lists/*


# Set up Docker socket
RUN rm -f /var/run/docker.sock && \
  mkdir -p /var/run && \
  touch /var/run/docker.sock && \
  chmod 666 /var/run/docker.sock

# Create Docker socket symlink
RUN ln -sf /var/run/podman/podman.sock /var/run/docker.sock

COPY /containers.conf /etc/containers/containers.conf
COPY /podman-containers.conf /home/node/.config/containers/containers.conf

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
VOLUME /swap

RUN mkdir -p /var/lib/shared/overlay-images \
  /var/lib/shared/overlay-layers \
  /var/lib/shared/vfs-images \
  /var/lib/shared/vfs-layers && \
  touch /var/lib/shared/overlay-images/images.lock && \
  touch /var/lib/shared/overlay-layers/layers.lock && \
  touch /var/lib/shared/vfs-images/images.lock && \
  touch /var/lib/shared/vfs-layers/layers.lock && \
  chown -R node:node /var/lib/shared

ENV _CONTAINERS_USERNS_CONFIGURED="" \
  BUILDAH_ISOLATION=chroot \
  DOCKER_HOST="unix:///var/run/docker.sock"

# Set up container storage for node user
RUN mkdir -p /home/node/.local/share/containers && \
  chown -R node:node /home/node/.local/share/containers

RUN touch /etc/containers/nodocker

COPY ./90-node-swap-perms /etc/sudoers.d/90-node-swap-perms
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER node
WORKDIR /home/node

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"] 
