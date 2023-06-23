## Stage 1 : Golang build
## ----------------------
## https://docs.docker.com/develop/develop-images/dockerfile_best-practices
## https://docs.docker.com/engine/reference/builder/ 
## https://hub.docker.com/_/golang/ 
# FROM golang:1.15.8 AS builder
FROM golang:1.19.2 AS builder

ARG PKG_NAME
ARG MODULE
ARG VENDOR
ARG SVN
ARG VER
ARG BUILT

ARG ARCH
ENV CGO_ENABLED 0
ENV GOARCH      $ARCH
ENV GOHOSTARCH  $ARCH

WORKDIR /work
COPY . .
## To download modules, but we rather COPY all (above) instead.
# RUN go mod download -x

WORKDIR /work/app/${PKG_NAME}
RUN go build -a -ldflags="\
    -X '${MODULE}/app.Maker=${VENDOR}' \
    -X '${MODULE}/app.SVN=${SVN}' \
    -X '${MODULE}/app.Version=${VER}' \
    -X '${MODULE}/app.Built=${BUILT}'"

## Stage 2 : https://hub.docker.com/_/alpine/ 
## ------------------------------------------
FROM alpine:3.16.3
LABEL image.base.name="hub.docker.com/_/alpine/alpine:3.16.3"

ARG PKG_NAME
ARG PKG_DESC
ARG ARCH
ARG HUB
ARG PRJ
ARG MODULE
ARG AUTHORS
ARG VENDOR
ARG SVN
ARG VER
ARG BUILT

## Labels abide OCI spec for Annotation Keys
## https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys 
LABEL image.authors="${AUTHORS}"
LABEL image.created="${BUILT}"
LABEL image.description="${PKG_DESC}"
LABEL image.url="https://hub.docker.com/repository/docker/${HUB}/${PRJ}.${PKG_NAME}-${ARCH}"
LABEL image.revision="${SVN}"
LABEL image.source="https://github.com/sempernow/${PRJ}"
LABEL image.title="${PKG_NAME}"
LABEL image.vendor="${VENDOR}"
LABEL image.version="${VER}"

## Alpine packages : https://pkgs.alpinelinux.org/packages
RUN apk update \
    && apk --no-cache add jq \
    && rm -rf /var/cache/apk/*

## @ tzdata : https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# ENV TZ America/New_York

RUN mkdir -p /app/assets

ENV PATH="/app:${PATH}"

COPY --from=builder /work/app/${PKG_NAME}/${PKG_NAME} /app/main

WORKDIR /app
CMD ["sleep", "1d"]

