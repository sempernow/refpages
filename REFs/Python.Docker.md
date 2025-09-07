# Python : Containerized Dev Box | [`hub.docker.com`](https://hub.docker.com/_/python/tags?page=1&name=3.7.15) | [`docs.python.org`](https://docs.python.org/release/3.7.15/)


## TL;DR

```bash
# Start the dev box
☩ img='python:3.7.15'
☩ docker run -d --rm --name pbox \
    -p 8888:8888 \
    -v $(pwd)/app:/usr/src/app \
    -w /usr/src/app \
    $img sleep 1d
# Exec an interactive shell therein
☩ docker exec -it $img bash
```

@ `root@186afc9f08ac:/usr/src/app#` (`pbox` container)

```bash
# Install pipreqs : to generate 'requirements.txt' 
python -m pip install pipreqs
# Generate the requirements.txt
## The list of all modules (versioned) required to run 
## this project (./*.py) in the context of this Python (python) version.
pipreqs .
# Install those dependencies (modules@versions)
python -m pip install -r requirements.txt
# Run the app
python app.py
```

## Images

Use a fully-loaded Python distro for development. 
Bitnami's is half the size of Python.org's, but lacks `pip` and other helpers.

```bash
☩ docker image ls
REPOSITORY                       TAG       IMAGE ID       CREATED        SIZE
bitnami/python                   3.7.15    c5d0a736cc3f   7 months ago   557MB
python                           3.7.15    7c36701f2ac5   7 months ago   907MB
```

## Meta Demos

Deploy a Python box having bind mount to local app folder

```text
☩ tree
.
├── app
│   ├── v1
│   │   ├── templates
│   │   └── web
│   │       ├── css
│   │       └── nfs
│   │           ├── sub1
│   │           │   └── bar
│   │           └── foo
│   └── dir.html
├── infra
│   └── docker
│       └── Dockerfile
├── README.md
└── tree.log

9 directories, 6 files
```

```bash
# Run the python directory server from inside the container
☩ port='8080'
☩ docker run -d --rm --name pbox \
    -p $port:$port \
    -v $(pwd)/app:/usr/src/app $img \
    python -m http.server $port \
        --bind 127.0.0.1 \
        --directory /usr/src/app/v1/web/nfs

# Exec an interactive shell therein
☩ docker exec -it pbox bash
```

From inside the container, hit the server's lone endpoint.

@ `root@d6c12e690057:/#`

```bash
# Perform a GET request using HTTP-client utility cURL
## and log STDOUT for posterity; to host FS, thanks to bind mount.
curl -sI localhost:8080 |tee curl-I.localhost.8080.log
```
```text
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.7.15
Date: Fri, 21 Jul 2023 15:09:43 GMT
Content-type: text/html; charset=utf-8
Content-Length: 363
```

## Dockerfile

```Dockerfile
# syntax=docker/dockerfile:1
##... Docker BuildKit 
ARG SOURCE=python:3.7.15

## Stage 1
FROM ${SOURCE} AS builder

WORKDIR /app

## Prevent Python interpreter from generating cruft files
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

## GCC compiler is required for installing certain Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

## Install dependencies using Wheels
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

## Stage 2
FROM bitnami/${SOURCE}

## Run as unprivileged user
RUN addgroup --system app && adduser --system --group app
## OR also REMOVE SHALL ACCESS and home dir. 
## To randomize IDs, don't specify IDs (--gid 1001, --uid 1001).
#RUN addgroup --gid 1001 --system app && \
#    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app

USER app
WORKDIR /app

COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

RUN pip install --no-cache /wheels/*

COPY app.py .

CMD [ "python", "app.py" ] 
```

To implement [Gunicorn](https://pypi.org/project/gunicorn/#description "@ PyPI") (Python WSGI HTTP Server) for Flask, use this `CMD` at `Dockerfile`. 

```bash
CMD ["gunicorn", "--bind", "0.0.0.0:5555", "{subfolder}.{file_name}:{flask_name}"]
```
- If main module is in root folder with file name `main.py`, and has Flask-instance variable name `myapp`, then the final command arg (above) is just "`main:myapp`". If that app is moved to subfolders, then the arg becomes "`subfolder1_name.subfolder2_name.main:myapp`"
-  Set workers: `-w 4`