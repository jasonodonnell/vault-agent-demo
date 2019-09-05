.PHONY:	all build

# Default target
all: build

build:
	docker build --no-cache -t vault-agent ./build
	docker tag vault-agent hashicorp/vault-agent:0.0.1
