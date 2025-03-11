# Amplify PIND (Podman-in-Docker)

A solution for running Podman inside Docker containers with Node.js, specifically designed for AWS Amplify build environments. This project enables container builds in AWS Amplify by implementing a Node.js + Podman-in-Docker setup using a rootless configuration.

## Overview

AWS Amplify doesn't support Docker builds out of the box. This project provides a workaround by implementing Podman (a daemonless container engine) inside a Node.js-based Docker container. The implementation uses a rootless Podman configuration on top of a Debian-based Node.js image.

## Features

- Rootless Podman configuration for secure container operations
- Node.js environment (v20) as the base image
- Docker API compatibility layer through Podman
- Configurable container runtime with proper namespace isolation
- Support for both x86_64 and arm64 architectures

## Prerequisites

- Docker or compatible container runtime
- AWS Amplify environment (for deployment)

## Configuration Files

### containers.conf
The main configuration file for Podman containers, setting up:
- Host network namespace
- Host user namespace
- Host IPC namespace
- Host UTS namespace
- Host cgroup namespace
- Disabled cgroups
- k8s-file logging driver

### podman-containers.conf
User-specific container configuration for the node user.

## Usage

1. Build the container:
```bash
docker build -t amplify-pind .
```

2. Run the container:
```bash
docker run --privileged -v /var/lib/containers -v /home/node/.local/share/containers amplify-pind
```

## Key Components

### Dockerfile Highlights

- Base image: Node.js (configurable version, default v20)
- Podman installation with Docker compatibility layer
- Proper volume configuration for container storage
- Rootless setup for the node user
- Custom storage configuration for optimal performance

### Security Considerations

- Runs in rootless mode for enhanced security
- Uses user namespaces for isolation
- Configurable UIDs and GIDs for container processes
- Minimal privilege requirements while maintaining functionality

## Environment Variables

- `_CONTAINERS_USERNS_CONFIGURED`: Container namespace configuration
- `BUILDAH_ISOLATION`: Set to "chroot" for build isolation
- `DOCKER_HOST`: Unix socket path for Docker API compatibility

## Volume Mounts

The container requires two volume mounts:
- `/var/lib/containers`: For container storage
- `/home/node/.local/share/containers`: For user-specific container data

## AWS Amplify Integration

To use this in AWS Amplify:

1. Reference this container in your Amplify build configuration
2. Ensure the build environment has the necessary privileges
3. Configure your build steps to utilize the Podman/Docker compatibility layer

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on the [Podman in Docker](https://www.redhat.com/en/blog/podman-inside-container) concept by Red Hat
- Adapted for AWS Amplify build environments
- Modified to work with Node.js base image instead of Red Hat distribution 
