# https://docs.docker.com/develop/develop-images/dockerfile_best-practices
# https://docs.docker.com/engine/reference/builder/ 
# GoogleContainerTools/distroless 
# https://github.com/GoogleContainerTools/distroless
FROM gcr.io/distroless/static
LABEL image.base.name="gcr.io/distroless/static"

ARG HUB
ARG MODULE
ARG VER

# https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys 
LABEL image.description="For any Golang binary built with CGO disabled."
LABEL image.source="https://github.com/GoogleContainerTools/distroless"
LABEL image.url="https://hub.docker.com/repository/docker/${HUB}/sans.static"
LABEL image.version="${VER}"
