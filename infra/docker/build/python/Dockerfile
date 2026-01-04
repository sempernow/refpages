# syntax=docker/dockerfile:1
##... Docker BuildKit 
## https://hub.docker.com/_/python
## https://hub.docker.com/r/bitnami/python

## Stage 1
#FROM python:3.7.15 AS builder
FROM python:3.9.17 AS builder

WORKDIR /app

## Prevent Python interpreter from generating cruft files
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

## GCC compiler is required for installing certain Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

## Install dependencies 
COPY requirements.txt .
#RUN python -m pip install --no-cache-dir -r requirements.txt
## ... using Wheels
RUN python -m pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

## Stage 2
#FROM bitnami/python:3.7.15
FROM bitnami/python:3.9.17

## Run as unprivileged user
RUN addgroup --system app && adduser --system --group app
## OR also REMOVE SHALL ACCESS and home dir. 
## To randomize IDs, don't specify IDs (--gid 1001, --uid 1001).
#RUN addgroup --gid 1001 --system app && \
#    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app

WORKDIR /app

COPY v1 ./v1
COPY app.py .
#COPY requirements.txt .
#RUN python -m pip install --no-cache -r requirements.txt

COPY --from=builder /app/wheels /wheels
RUN python -m pip install --no-cache /wheels/*

RUN chown -R app:app .
USER app

CMD [ "python", "app.py" ]


## https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys 
# LABEL image.authors="${AUTHORS}"
# LABEL image.created="${BUILT}"
LABEL image.from="bitnami/python:3.9.17"
# LABEL image.hub="https://hub.docker.com/repository/docker/${HUB}/${PRJ}.${PKG_NAME}-${ARCH}"
# LABEL image.revision="${SVN}"
# LABEL image.source="https://${MODULE}/app/${PKG_NAME}"
# LABEL image.title="${PKG_NAME}"
# LABEL image.vendor="${VENDOR}"
# LABEL image.version="${VER}"
