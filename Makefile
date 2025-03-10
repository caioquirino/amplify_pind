# Image name and tag
IMAGE_NAME = amplify_pind
IMAGE_TAG = latest
NODE_VERSION ?= latest

# Build the Docker image
.PHONY: build
build:
	docker build --build-arg NODE_VERSION=$(NODE_VERSION) -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Build for specific Node.js versions
.PHONY: build-node20
build-node20:
	docker build --build-arg NODE_VERSION=20 -t $(IMAGE_NAME):node20 .

.PHONY: build-node22
build-node22:
	docker build --build-arg NODE_VERSION=22 -t $(IMAGE_NAME):node22 .

# Run the container with required security options
.PHONY: run
run:
	docker run -it \
		--privileged \
		--user node \
		$(IMAGE_NAME):$(IMAGE_TAG)

# Run specific Node.js version
.PHONY: run-node20
run-node20:
	docker run -it \
		--privileged \
		--user node \
		$(IMAGE_NAME):node20

.PHONY: run-node22
run-node22:
	docker run -it \
		--privileged \
		--user node \
		$(IMAGE_NAME):node22

# Clean up the image
.PHONY: clean
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):node20 $(IMAGE_NAME):node22

# Default target
.DEFAULT_GOAL := build 