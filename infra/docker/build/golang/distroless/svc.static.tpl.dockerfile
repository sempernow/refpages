######################################################################
####  TEMPLATE for svc.static.dockerfile : See `make buildstatic`  ###
######################################################################
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
ENV GOARCH      $ARCH
ENV GOHOSTARCH  $ARCH
ENV CGO_ENABLED 0

RUN mkdir -p /work/distroless_RUN_mkdir
WORKDIR /work
## Copy entire project (5s), or only select dirs (2s). 
COPY . .
# COPY go.mod ./
# COPY go.sum ./
# COPY app    ./app
# COPY data   ./data
# COPY kit    ./kit
# COPY vendor ./vendor

## To download modules, but we rather COPY all (above) instead.
# RUN go mod download -x

WORKDIR /work/app/${PKG_NAME}
RUN go build -a -ldflags="\
    -X '${MODULE}/app.Maker=${VENDOR}' \
    -X '${MODULE}/app.SVN=${SVN}' \
    -X '${MODULE}/app.Version=${VER}' \
    -X '${MODULE}/app.Built=${BUILT}'"

## Stage 2 : Use static (Distroless) if cgo DISABLED @ go build, else use base.
## ----------------------------------------------------------------------------
FROM gd9h/sans.static:DISTROLESS_TAG
LABEL image.base.name="hub.docker.com/repository/docker/gd9h/sans.static:DISTROLESS_TAG"

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

## Distroless has no `RUN mkdir ...` capability, so mkdir per COPY of empty subdir.
COPY --from=builder /work/distroless_RUN_mkdir /app/assets
## Copy only the built binary.
COPY --from=builder /work/app/${PKG_NAME}/${PKG_NAME} /app/main

WORKDIR /app
CMD ["/app/main"]
