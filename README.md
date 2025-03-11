# Amplify PIND (Podman-in-Docker)

A solution for running Podman inside Docker containers with Node.js, specifically designed for AWS Amplify build environments. This project enables container builds in AWS Amplify by implementing a Node.js + Podman-in-Docker setup using a rootless configuration.

## Overview

AWS Amplify doesn't support Docker builds out of the box. This project provides a workaround by implementing Podman (a daemonless container engine) inside a Node.js-based Docker container. The implementation uses a rootless Podman configuration on top of a Debian-based Node.js image.

## AWS Amplify Integration

To use this in AWS Amplify:

1. Open AWS Amplify Console
2. Open your Application
3. In Hosting, navigate to the Build settings page
4. At the Build image settings, click on Edit
5. At the Build image section, select Custom Build Image
6. Fill the Custom Build Image field with the appropriate image (example: `caioquirino/amplify_pind:node22`)

## Features

- Rootless Podman configuration for secure container operations
- Node.js environment as the base image
- Docker API compatibility layer through Podman
- Configurable container runtime with proper namespace isolation
- Support for both x86_64 and arm64 architectures
- Available as pre-built images on Docker Hub

## Docker Hub Images

The pre-built images are available on Docker Hub:

```bash
docker pull caioquirino/amplify-pind:latest
```

Available tags:
- `latest`: Latest stable release (currently Node.js 22)
- `node22`: Node.js v22.x based image
- `node20`: Node.js v20.x based image
- `node18`: Node.js v18.x based image

Each Node.js version tag is available for both x86_64 and arm64 architectures.

Example using a specific Node.js version:
```bash
# For Node.js 22
docker pull caioquirino/amplify-pind:node22

# For Node.js 20
docker pull caioquirino/amplify-pind:node20

# For Node.js 18
docker pull caioquirino/amplify-pind:node18
```

## Configuration Files

### containers.conf
The main configuration file for Podman containers, setting up:
- Host network namespace
- Host user namespace
- Host IPC namespace
- Host UTS namespace
- Host cgroup namespace
- Disabled cgroups
User-specific container configuration for the node user.

## Usage

### Using Pre-built Image

1. Pull the image:
```bash
docker pull caioquirino/amplify-pind:latest
```

2. Run the container:
```bash
docker run --privileged -v /var/lib/containers -v /home/node/.local/share/containers caioquirino/amplify-pind:latest
```

### Building Locally

If you need to customize the image:

The main configuration file for Podman containers, setting up:
```bash
docker build -t amplify-pind .
```

2. Run the container:
```bash
docker run --privileged -v /var/lib/containers -v /home/node/.local/share/containers amplify-pind
```

## Key Components

### Dockerfile Highlights

- Base image: Node.js (configurable version)
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

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

This project is licensed under the GNU General Public License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on the [Podman in Docker](https://www.redhat.com/en/blog/podman-inside-container) concept by Red Hat
- Adapted for AWS Amplify build environments
- Modified to work with Node.js base image instead of Red Hat distribution 
