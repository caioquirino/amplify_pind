# Image name and tag
IMAGE_NAME = amplify_pind
IMAGE_TAG = latest

# Build the Docker image
.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run the container with required security options
.PHONY: run
run:
	docker run -it \
		$(IMAGE_NAME):$(IMAGE_TAG)


enter:
	docker run -it \
		$(IMAGE_NAME):$(IMAGE_TAG) bash

# Clean up the image
.PHONY: clean
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

# Default target
.DEFAULT_GOAL := build 