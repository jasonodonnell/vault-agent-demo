# Builder
ARG VERSION=1.13.10

FROM golang:${VERSION} AS builder

ARG CGO_ENABLED=0
ARG BUILD_TAGS

WORKDIR /go/src/github.com/hashicorp/app
COPY . .

RUN make build

RUN cp agent-inject-demo-app /go/bin/app

# App Image

FROM alpine:latest

ARG VERSION=1.0.0

RUN addgroup app && \
    adduser -S -G app app

COPY --from=builder /go/bin/app /app

USER app

ENTRYPOINT ["/app"]
