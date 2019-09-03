.PHONY:	all build

# Default target
all: build

build:
	docker build -t vault-agent .
	docker tag vault-agent hashicorp/vault-agent:0.0.1
