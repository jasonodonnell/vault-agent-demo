IMAGE_NAME=app
VERSION?=1.0.0
BUILD_DIR=.build
GOOS?=linux
GOARCH?=amd64
BIN_NAME=$(IMAGE_NAME)_$(GOOS)_$(GOARCH)_$(VERSION)

.PHONY: all build clean
all: clean

build:
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -a .

clean:
	-rm -rf $(BUILD_DIR)
