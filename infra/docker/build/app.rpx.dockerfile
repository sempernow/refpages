# https://docs.docker.com/develop/develop-images/dockerfile_best-practices
# https://docs.docker.com/engine/reference/builder/ 
# https://hub.docker.com/_/nginx/
# https://nginx.org/en/CHANGES
# https://hub.docker.com/r/nginxinc/nginx-unprivileged 
# https://www.nginx.com/blog/deploying-nginx-nginx-plus-docker/
# https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/ 
#FROM nginx:1.19.3-alpine
FROM nginx:1.22.1-alpine

ARG PKG_NAME
ARG ARCH
ARG HUB
ARG PRJ
ARG MODULE
ARG AUTHORS
ARG VENDOR
ARG SVN
ARG VER
ARG BUILT

# .... do things here ...

CMD ["nginx", "-g", "daemon off"]
# "... -g daemon off ... in order for nginx to stay in the foreground, so that Docker can track the process properly (otherwise your container will stop immediately after starting)!"

# https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys 
LABEL image.authors="${AUTHORS}"
LABEL image.created="${BUILT}"
LABEL image.from="alpine"
LABEL image.hub="https://hub.docker.com/repository/docker/${HUB}/${PRJ}.${PKG_NAME}-${ARCH}"
LABEL image.revision="${SVN}"
LABEL image.source="https://${MODULE}/app/${PKG_NAME}"
LABEL image.title="${PKG_NAME}"
LABEL image.vendor="${VENDOR}"
LABEL image.version="${VER}"
