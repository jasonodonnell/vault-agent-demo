FROM alpine:latest

ARG VERSION=1.0.0

RUN addgroup app && \
    adduser -S -G app app

ADD .build/app_linux_amd64_$VERSION /app

USER app

ENTRYPOINT ["/app"]
