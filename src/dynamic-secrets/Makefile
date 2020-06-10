IMAGE_NAME=app
VERSION?=1.0.0
IMAGE_TAG=$(REGISTRY_NAME)/$(IMAGE_NAME):$(VERSION)
IMAGE_TAG_LATEST=$(REGISTRY_NAME)/$(IMAGE_NAME):latest
DOCKER_DIR=./build
BUILD_DIR=.build
GOOS?=linux
GOARCH?=amd64
BIN_NAME=$(IMAGE_NAME)_$(GOOS)_$(GOARCH)_$(VERSION)

.PHONY: all test build image clean
all: clean image push

build:
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -a -o $(BUILD_DIR)/$(BIN_NAME) .

image: build
	docker build --no-cache -t app -f ./build/Dockerfile .
	docker tag app hashicorp/dynamic-secrets-app:$(VERSION)

clean:
	-rm -rf $(BUILD_DIR)
