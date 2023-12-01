exit
# REFs
#   Dockerfile Ref  https://docs.docker.com/reference/dockerfile 
#   Docker Ref      https://docs.docker.com.zh.xy2401.com/  (China)
#   Docker Hub      https://hub.docker.com/explore/  
#   Wikipedia       https://en.wikipedia.org/wiki/Docker_%28software%29 
# 
# Use PowerShell or mintty (Git for Windows)
    winpty bash  # @ mintty (MINGW64), launches TTY pseudo terminal @ bash subshell. 
# DfW/DfM (v17.06)
    # Certificates-based login to registry
    # DNS host-name accessible from containers: docker.for.{win|mac}.localhost  
# Docker EE : Universal Control Plane (Web UI)
# Dockerfile  https://docs.docker.com/engine/reference/builder/
    # syntax=docker/dockerfile:1
    #… Required for advanced features of BuildKit; *must* be 1st line.
    # Best Practices  https://docs.docker.com/build/building/best-practices/
    ARG FOO=bar             # Only the ARG command is allowed before 1st FROM command.
    ARG IMG                 # ARG is scoped to build environment
                            # Inject host env using flag(s): `docker build --build-arg IMG=$APP_BUILDER_IMG` 
                            # Its k=v are available to FROM of all build stages. 
                            # For access otherwise (ENV, LABEL, …), must (re)declare ARG per stage.
    FROM $IMG AS builder    # Source image; Base layer of this image 
    ARG IMG                 # Must (re)declare at each build stage for ENV, LABEL, … to access it there
    ENV IMG=${IMG}          # ENV requires both (k=v) and PERSISTS in image/container
    ARG FOO                 # Scoped to build stage. Re(Set) : docker buildx --build-arg FOO=bar
    ARG FOO=foo             # Override that during build.
    ARG BAR foo             # Equivalent DEPRICATED syntax.
    ENV FOO=22              # This local OVERRIDEs that declared at flag: `docker … -e FOO=z`
                            # PREDEFINED ARGs : https://docs.docker.com/reference/dockerfile/#predefined-args
    WORKDIR /app            # Set the image $PWD; creates dir if not exist.
                            # Rather declare port-map params and set at runtime by environment.
    COPY . .                # Copy (recursively) from host $PWD to image $PWD, which is presently /app.
    COPY ./foo ./dst        # Creates destination dir if not exist.
    COPY --from=builder /bldr/src ./some/dst  #… source FS from a prior, named stage.
    RUN mkdir -p /foo/bar   # RUN any shell command(s); chain (&&) where feasible.
    RUN apk update \
        && apk --no-cache add ca-certificates curl jq tzdata \
        && rm -rf /var/cache/apk/* #… chain commands to install packages.
    ADD https://grab.com/tarball.tgz /dst # Prefer COPY lest URL; *extracts* to /dst
    # LABELs : Use only OCI spec k=v for Annotation Keys
    # https://specs.opencontainers.org/image-spec/annotations/ 
    ARG APP_BUILD_IMAGE # Inject host environment for access by LABEL.
    LABEL org.opencontainers.image.authors="Dev Team <devteam@example.com>"
    LABEL org.opencontainers.image.build.image="${APP_BUILD_IMAGE}"
    # ENTRYPOINT; the binary or shell script (pid 1) executed upon container launch; 2 forms:
    ENTRYPOINT ["/app/executable", "arg1", "arg2"]  # "exec form", PREFERRED; JSON array syntax.
    ENTRYPOINT /app/executable arg1 arg2            # "shell form" is DEPRICATED.
    # The ENTRYPOINT instruction is NOT overridable at commandline or YAML (upon container launch).
    # CMD; same as ENTRYPOINT, but merely sets default(s); overridable; 3 forms:
    CMD ["arg3", "arg4"]                       # DEFAULT; appends (additional) args to ENTRYPOINT. 
    CMD ["/app/executable", "arg1", "arg2"]    # "exec form"; PREFERRED; JSON array syntax.  
    CMD /app/executable arg1 arg2              # "shell form" is DEPRICATED.
    # CMD is OVERRIDDEN by any CLI args at commandline; 
    # `docker run …`, or YAML `command:` declaration.
    # If multiple CMD statements, only the last one is executed.
    # If both ENTRYPOINT & CMD include execcutables, then BOTH are executed, sequentially.

# CLI Tools
docker 
docker-compose 
docker-machine

# Restart Docker daemon : if Linux/install @ systemd
sudo systemctl restart docker

# Docker Registry v2 API 
    # https://distribution.github.io/distribution/spec/api/
    # Note regarding "digest" in documentation (across the web) : 
    #     "the digest" may refer to the MANIFEST DIGEST,
    #      any digest of any layer thereof,
    #      OR to a REPO DIGEST, which is <registry>/<repo>@sha256:<manifest-digest>. 
    #      - That reported by `docker image ls --digests …` is the manifest digest.
    #      - That required by registry v2 is the manifest digest.
    #      - Neither are IMAGE ID, which is analog to manifest, but context is local cache.

    # Validate the registry abides /v2/
        registry=index.docker.io
        curl -I https://$registry/v2/ #=>
            # HTTP/1.1 401 Unauthorized                       <<< REQUIRED of v2
            # content-type: application/json
            # docker-distribution-api-version: registry/2.0   <<< REQUIRED of v2
            # www-authenticate: Bearer realm="https://auth.docker.io/token",service="registry.docker.io"
            # … The WWW-Authenticate header value provides token-request params, so …

    # GET token : scoped to app
        # See WWW-Authenticate header for the actual auth endpoint, which may differ per registry"
        curl "https://$registry/token?service=registry.docker.io&scope=repository:$app:pull"
            # {"token":"…","access_token": "…", …}

    # GET manifest : Response includes manifest digest in its "Docker-Content-Digest" HEADER.
        ## E.g., "Docker-Content-Digest: sha256:c230832bd3b0b…"
        ## @ v2.3+, with GET or HEAD request MUST include these headers 
        ## else returns a bogus manifest in the docker-content-digest response header:
        auth="Authorization: Bearer $token"
        accept='Accept: application/vnd.docker.distribution.manifest.v2+json'
        repo=''
        app='busybox'
        name="$repo/$app"
        tag='latest'
        curl -H "$auth" -H "$accept" -isS https://$registry/v2/$name/manifests/$tag 

    # GET catalog of its image repos : JSON response body
        curl -s http://$registry/v2/_catalog  # {"repositories: ["repo/app:tag",…]"}

    # GET tags/list : all tags of an image APP : JSON response body
        curl -X GET -u $user:$pass \
            https://$registry/v2/$name/tags/list \
            |tee list.$app.tags.json # {"name":"repo/app","tags":["a","b",…]}

    # GET all content of container registry; all images of all repos,
    # in flat-list format : [REPO/]APP:TAG 
        curl -s http://$registry/v2/_catalog \
            |jq -Mr .[][] \
            |xargs -I{} curl -s http://$registry/v2/{}/tags/list \
            |jq -Mr '.tags[] as $tag | "\(.name):\($tag)"'
                # busybox:1.31.1-musl
                # nginx:1.25-alpine3.18
                # nginx:1.25.4-alpine-otel
                # redhat/ubi8:8.7

    # GET all content of container registry, both repos and images lists, 
    # in BOTH formats : JSON and flat-list.
        curl -s http://$registry/v2/_catalog \
            |tee catalog.json \
            |jq -Mr .[][] \
            |tee catalog.repositories.log \
            |xargs -I{} curl -s http://$registry/v2/{}/tags/list \
            |jq -Mr . --slurp \
            |tee all.tags.list.json \
            |jq -Mr '.[] | .tags[] as $tag | "\(.name):\($tag)"' \
            |tee all.images.log

    # DELETE an image from Registry v2 
        # 1. HEAD : returns the manifest digest required of any subsequent DELETE request.
            # Digest is returned in HTTP response header: "Docker-Content-Digest: sha256:abc…123"
            auth="Authorization: Bearer $token"
            accept='Accept: application/vnd.docker.distribution.manifest.v2+json'
            registry=us-west1-docker.pkg.dev
            repo=gd9h
            app=prj3.aoa-amd64
            name="$repo/$app"
            tag='latest'
            digest="$(
                curl -H "$accept" -H "$auth" -siSX HEAD \
                    https://$registry/v2/$name/manifests/$tag \
                    |grep -i docker-content-digest \
                    |awk '{printf "%s\n",$2}' \
                    |sed 's/\W//g' \
                    |sed 's/sha256/sha256:/' \
            )"  
                # HTTP/1.1 200 OK
                # …
                # docker-content-digest: sha256:521…945
                # …
                    # Note the /v2 API will FAIL SILENTLY, REGARDLESS of reason 
                    # (auth fail, no Accept header, …). 
                    # Yet its HEAD response ALWAYS INCLUDES a digest. 
                    # The sole distinction between success and failure 
                    # is that the digest is real on success and bogus on failure.
                    # Attempting step 2 or other /manifest/ request with bogus digest will fail (HTTP 4xx or 5xx)
        # 2. DELETE : /v2/<app>/manifests/<reference> : '<reference>' is REGISTRY DIGEST of step 1.
            # HTTP 202 response on success
            curl -H "$auth" -H "$accept" -sSX DELETE \
                https://$registry/v2/$name/manifests/$digest 

    # Run a PRIVATE (local) Registry : CNCF Distribution Registry
        # https://distribution.github.io/distribution/
        docker run --rm -d --restart always --name registry \
            -p 5000:5000 \
            -v /tmp/local_registry:/var/lib/registry \
            registry:2.8.3
        # If want local DNS resolution of registry.local:5000
        export reg='registry.local'
        echo "127.0.0.1 $reg" |sudo tee /etc/hosts
        docker tag abox:v0.1.2 $reg:5000/abox:v0.1.2
        docker push $reg:5000/abox:v0.1.2
        docker image ls # … registry.local:5000/abox     v0.1.2 …

    # PUSH image in local cache to registry : Use docker (client)
        docker tag $app:$tag $registry/$app:tag
        docker push $registry/$app:tag

    # PUSH all in local docker cache to registry
        dit (){
            function d(){
                docker image ls --format "table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}" $@
            }
            h="$( d |head -n1)"
            echo "$h"
            d "$@" |grep -v REPOSITORY |sort -t' ' -k2
        }
        export -f dit
        dit |grep -v $registry |grep -v IMAGE |awk '{print $2}' \
            |xargs -IX /bin/bash -c \
                'docker tag $1 $0/$1 && docker push $0/$1' $registry X

# K8s-API Client : secure kubectl container
    docker run -it --rm \
        -v ~/.kube/config:/home/nonroot/.kube/config \
        cgr.dev/chainguard/kubectl:latest get pods
# Docker in Docker (DinD) : https://hub.docker.com/_/docker
    # Use to build images in a (containerized) CI pipeline, such as at Jenkins, GitLab, …
    docker run -it -v /var/run/docker.sock:/var/run/docker.sock docker
# Docker-out-of-Docker (DooD) 
    # Predecessor to DinD : Prefer DinD to DooD
    # Exploit a host's Docker server; it listens on UNIX SOCKET /var/run/docker.sock 
    # Build & run container that has only docker (CLI) installed; mount host's docker.sock
        # Dockerfile : Build $_IMG
            FROM alpine:3.16.3
            RUN apk update && apk --no-cache add docker-cli && rm -rf /var/cache/apk/*
            CMD ["sleep", "1d"]
        docker build -t $_IMG .
        # Run docker client @ container, yet comms to host's docker server, per bind mount to host's docker.sock:
            docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock $_IMG docker version
            #… if require only reads, then use `ro` option: `-v HOST:CTNR:ro`
# Docker daemon API access via UNIX SOCKET : Request/Response @ SERVER (daemon) HOST:
    curl -s --unix-socket /var/run/docker.sock http://localhost/version |jq .
    # https://docs.docker.com/engine/api/v1.40/
        # /version  docker ps
        # /images/json
        # /containers/json
        # …
    # On err
    sudo chmod 666 /var/run/docker.sock
    # Docker Engine AKA Docker Server AKA Docker Daemon
        systemctl status docker.service	
    # Config listening address to other than default (tcp:0.0.0.0:2375)
        # This is WSL2 setup, which allows containerized Triy scans to function:
        # UPDATE : docker-proxy handles this now. See docker.service of systemd 
        ip -4 -brief addr show dev eth0 #=> eth0    UP    172.25.164.157/20
        #>>>  PRESERVE TABs of heredoc  <<<
		cat <<-EOH |sudo tee /etc/docker/daemon.json
		{
		  "hosts": [
		    "tcp://172.25.164.157:2375",
		    "unix:///var/run/docker.sock"
		    ]
		}
		EOH
    # @ Journald
        sudo journalctl -u docker.service --no-pager -n 50		
    # @ WSL2 : Forward WSL2 port to Windows host using PowerShell:
        netsh interface portproxy add v4tov4 listenport=2375 listenaddress=0.0.0.0 connectport=2375 connectaddress=127.0.0.1
    # @ systemd : Override the default unit file by adding a drop-in file
        # Removing the default flag `-H fd://`, which allows systemd to set the socket,
        # we must otherwise declare the listening socket, 
        # as done above (/etc/docker/daemon.json)
        sudo mkdir -p /etc/systemd/system/docker.service.d
        #>>>  PRESERVE TABs of heredoc  <<<
		cat <<-EOH |sudo tee /etc/systemd/system/docker.service.d/override.conf
		[Service]
		ExecStart=
		ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock
		EOH
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        sudo systemctl status docker
        # @ dev environment, may want to delete all prior journald logs
            sudo systemctl stop systemd-journald
            sudo rm -rf /var/log/journal/*/*.journal
            sudo systemctl start systemd-journald
# Memory/CPU/… Resource Constraints : Runtime options 
    # https://docs.docker.com/config/containers/resource_constraints/
    # https://ram.tianon.xyz/post/2021/03/16/docker-setup-reredux.html

docker  # CLI tool a.k.a. Docker Engine; the Docker Client of Docker Server (dockerd) 
    # CONFIG / OPTIONS 
        # https://docs.docker.com/engine/reference/commandline/dockerd/
        # https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
        dockerd --validate --config-file=/tmp/valid-config.json
        /etc/docker/daemon.json
        # AND/OR 
        ~/.docker/daemon.json
        # FIX @ DfW : WSL : export DOCKER_HOST=tcp://0.0.0.0:2375
        # https://stackoverflow.com/questions/63416280/how-to-expose-docker-tcp-socket-on-wsl2-wsl-installed-docker-not-docker-deskt
        # Win (nope!)
        %ProgramData%\docker\config\daemon.json
        # https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-user-namespace-options
    # Command Reference @ https://docs.docker.com/engine/reference/commandline/cli  
        docker version  # validate install 
        docker info     # identical @ WSL | Win10 
            Server Version:  19.03.4
            Docker Root Dir: /var/lib/docker
            Kernel Version:  4.9.184-linuxkit
            Storage Driver:  overlay2
                Backing Filesystem: extfs

    # LOGIN to Docker Hub (public images repository)
        docker login  # Requies auth only ONCE per platform/environment; 
        #… creds stored UNENCRYPTED, base64 encoded @ ~/.docker/config.json
        # OR, login using one liner sans prompt; pipe password to prevent recording it.
         echo "PASSWORD_OR_TOKEN" |docker login -u "$_USER" --password-stdin 
            # On ANY repeated ERRORS at LOGIN (ANY SORT; even HTTP 502, 503, …), 
            # FIX by: 
                # 1. Logout : docker logout
                # 2. Empty ~/.docker/config.json
					echo -n > ~/.docker/config.json
					# OR, at least empty teh 'auths' key : "auths": {}
                # 3. Login again (above method)
        docker logout # to remove creds (base64-encoded) from ~/.docker/config.json
    # (Travis-CI to Docker Hub logon FAILS if passwords have certain special chars)
    # LABEL : key only, OR k-v pair(s), on obects : image, container, volume, network, swarm node|service
        # https://docs.docker.com/engine/reference/commandline/node_update/
        docker $OBJ update --label-add "$k1=$v1"  --label-rm "$k3" --label-add "$l1" $OBJ_NAME
        docker node inspect $NODE_NAME |jq .[].Spec.Labels
            {
                "node": "1",
                "pvt": "true"
            }
        # @ YAML : deploy > placement > constraints
            deploy: # https://docs.docker.com/compose/compose-file/compose-file-v3/#deploy 
                replicas: 1
                placement:
                    constraints: 
                        - node.labels.pvt == true
    # FILTERing option; several docker commands allow it 
        --filter KEY=VALUE  
            # name|ancestor=IMAGE|label=KEY[=VALUE]|before=NAME
            # |since=NAME|exited=0(normal)|137(SIGKILL)
            # |status=created|restarting|running|removing|paused|exited
        # E.g.,  https://docs.docker.com/engine/reference/commandline/ps/#filtering
        --filter "before=clever_lovelace"
        --filter "label=foo"
        --filter "label=foo=bar"
    # HELP : get help for any Docker command …
        docker $_COMMAND --help |less
    # SYSTEM 
        docker system df       # disk usage 
        # PRUNE; Delete residue; if `… system`, then all ctnrs, vols, etc. not in use. 
        docker [system|container|volume|image] prune [-f]
        docker system prune --all --force   # @ Swarm node
        docker image prune --force          # @ docker-desktop
        docker buildx prune                 # Build cache 
    # IMAGEs image https://docs.docker.com/engine/reference/commandline/image/#child-commands  
        # Format to specify a repo (registry) image:
        [$_REGISTRY_HOSTNAME:$_REGISTRY_PORT]/$_REPO/$_APP:$_TAG  # Format 
        $_USERNAME/$_REPONAME:$_TAG     # … typical account AKA repo reference  
        # SEARCH / LIST @ Docker Hub 
            docker search $_APP    # Search Docker Hub  https://hub.docker.com/explore/  
            docker search $_REPO   # List all thereof
        # LIST (local)
            docker image ls             # list all images
            docker images               # list al images; alias
            docker images -q            # list all images; ID only
            docker image ls --digests   # show manifest digest : sha256:hhh…hhh
            # Format  https://docs.docker.com/engine/reference/commandline/images/#format-the-output
            # JSON 
            docker image ls --digests --format '{{json .}}' |jq -Mr . --slurp 
            # Table
            docker image ls \
                --format 'table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}' --digests
                --format 'table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.Digest}}'
                # OR
                --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}'  # default
        # DELETE image from local cache
            docker image rm $id  # delete image by id
            docker rmi $id       # delete image by id 
            docker rmi $repo/$name:$tag # delete image by tag (if image has only one tag).
            #… if image has other tags, then only that tag is deleted; image remains in local cache.
            docker rmi $(docker images -q)  # delete ALL images 
            # Delete a FILTERed list of images 
            docker images | grep "$_FILTER" |gawk '{print $3}' |xargs docker rmi
            drmi(){ [[ "$@" ]] && docker images |grep "$@" |gawk '{print $3}' |xargs docker rmi; }  
        # LAYERs @ (ls -l …)
            /var/lib/docker/$_STORAGE_DRIVER/diff  # Overlay2 (default) storage-driver 
            # Layer FS 
            ls -l /var/lib/docker/$_STORAGE_DRIVER/diff/$_SHA256
            docker history $_IMG
            docker inspect $_IMG
        # BUILDx https://docs.docker.com/engine/reference/commandline/buildx_build/
            # Build, tag, and push
            docker buildx build -t TAG --annotation "foo=bar" --push .
                # Other flags
                --sbom=true --provenance=true
        # BUILD (image)  https://docs.docker.com/engine/reference/commandline/build/#options  
            docker build [OPTIONS] PATH | URL | -
            docker buildx build .       # Use BuildKit
            ## build Docker image from Dockerfile per “context”; the set of files @ PATH or URL. 
            ## URL can be: 1. Git repo, 2. pre-packaged tarball, 3. plain text files.
            ## Inject ARG(s); exported environment variable(s); `=VAL` required only to (re)set
                --build-arg VAR[=VAL]   
            ## Labels : abide OCI spec for Annotation Keys
            ## https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys 
                --label KEY=VALUE       # good for subsequent `… --filter label=VALUE`  
                --compress              # gzip  
                --no-cache              # FORCE REBUILD 
            docker build .              # build image @ project dir, "." AKA The Build Context
            docker build -f a.dockerfile.at.pwd . # Sans -f, the Dockerfile expected (default) is "Dockerfile" 
            docker build -f $_PATH_to_Dockerfile $_PATH_to_DIR_of_Dockerfile 
            ## BUILD + TAG (all at once)
            docker build -t $_IMG_NAME:$_TAG .              # --tag; name and optionally tag (name:tag) 
            docker build -t $_REPO_NAME/$_IMG_NAME:$_VER  . # Format (convention) 
            docker build -t [$_REGISTRY_HOSTNAME[:$_REGISTRY_PORT]]/$_REPO_NAME/$_IMG_NAME:$_TAG  $_ABS_PATH
            #… Format full 
            # Alternate syntax
            docker buildx build - < Dockerfile
            cat Dockerfile |docker build -
            # BUILD from stdin ("-") per HEREDOC (sans Dockerfile)
				docker buildx build -t foo -f - . <<-EOH
				FROM busybox:1.34.1-musl
				CMD ls -ahl /
				EOH
            # MULTI-STAGE BUILDs  https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-build
                # syntax=docker/dockerfile:1
                ARG IMG_STAGE_1=${IMG_STAGE_1:-alpine:latest}
                # Build stage 
                FROM ${IMG_STAGE_1}
                FROM golang:alpine AS builder
                WORKDIR $GOPATH/src/app/
                COPY app.go .
                RUN go build -o /work/app
                # Deploy stage
                FROM scratch
                ENV IMG_STAGE_1=${IMG_STAGE_1}
                LABEL image.from="${IMG_STAGE_1}"
                COPY --from=builder /work/app /app
                CMD ["/app"]
        # TAG is actually NAME:TAG; NAME is _REPO_NAME/IMG_NAME
            # ADD
            docker tag $_SRC_IMG[:$_SRC_TAG] $_TGT_IMG[:$_TGT_TAG]
            # E.g., 
            docker tag '0e5574283393' 'fedora/httpd:version1.0'
            docker tag $_IMG_ID $_REPO_NAME/$_IMG_NAME:$_TAG
            # DELETE
            docker rmi NAME:TAG 
            # CHANGE REPO/IMAGE/TAG (RENAME)
            docker image tag nameOLD:tagOLD nameNEW:tagNEW
        # PUSH to repo (Docker Hub <<<  NOT  >>> docker.io)
            # *****************************************************************
            #  MUST `docker login` <<<  NOT  >>> "Sign in" @ Docker Desktop.
            # *****************************************************************
            docker push [$_REGISTRY_HOSTNAME:$_REGISTRY_PORT]/[$_REPO_NAME/]$_IMG_NAME:$_TAG  # Format
            docker push $_REPO_NAME/$_IMG_NAME:$_TAG  # login first if apropos; see LOGIN section
        # PULL from Registry (Repo) : DEFAULTs to Docker Hub
            docker pull [OPTIONS] NAME[:TAG|@DIGEST]
            # EQUIV to …
            docker image pull …
            # Pull from OTHER REGISTRY
            docker pull [$_REGISTRY_HOSTNAME:$_REGISTRY_PORT]/$_REPO_NAME/$_IMG_NAME:$_TAG 
            # E.g., 
            docker pull myregistry.local:5000/testing/test-image
            docker pull $aws_acct_id.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:2.0.20200722.0 
            # PRIVATE LOCAL Registry : Create/Use  https://rominirani.com/docker-tutorial-series-part-6-docker-private-registry-15d1fd899255
                docker pull registry # A registry is itself a Docker image 
                # Run the local registry 
                docker run -d --rm --name registry -p 5000:5000 registry:latest
                # Test: pull from local
                docker pull localhost:5000/alpine
                # Tag an image 
                docker tag $_IMG_NAME localhost:5000/$_IMG_NAME:$_TAG
                # Push to local registry
                docker push localhost:5000/$_IMG_NAME:$_TAG

    # CONTAINERs  https://docs.docker.com/engine/reference/commandline/container/ 
        # LIST container(s)
            docker container ls --all  # ALL; -a
            docker container ls        # all RUNNING  
                -q       # ID only 
                -s       # SIZE  
                -l       # LATEST 
                -n 4     # latest 4
            # per FORMAT/SELECT; per Golang template
                --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Names}}\t{{.Size}}\t{{.Ports}}"  
            # per filter (on IMAGE)
                image='ancestor=postgres:12.7-alpine'
                docker container ls -q --filter $image
            # per PROCESS; ls ALIAS; DEPRICATED command
            docker ps  
        # CREATE (container from image)  
            docker create $_IMG        # create container; prints CONTAINER_ID  
            # https://docs.docker.com/engine/reference/commandline/create/  
        # START (container)
            docker start $_CTNR     # start container   
            docker start -a $_CTNR  # --attach; start container; show its output
            docker start -ai $_CTNR # same as `…run -it…` for EXISTING (cached) container 
        # ATTACH local STDIN/OUT/ERR to RUNNING container (@ PID 1 only)
            docker attach $_CTNR    # `-it` into a running container
            # https://docs.docker.com/engine/reference/commandline/attach/  
            # … CTRL+P+Q to exit and LEAVE it RUNNING
        # EXECUTE a command @ RUNNING container  
            # https://docs.docker.com/engine/reference/commandline/exec/  
            docker exec -it $_CTNR CMD  # execute a command in a RUNNING container  
            docker exec -it $_CTNR sh   # launch shell into it; bash|powershell|zsh|sh  
            docker exec -it ctnr1 ping ctnr2  # ping one container from another, per DNS, not IP address. 
            docker exec -d $_CTNR touch /tmp/foo  # detached (bkgnd); create file foo @ CTNR /tmp
            # per container NAME (substring okay)
            docker exec -it $(docker ps -q --filter name=${_NAME} -n 1) sh -c 'nginx -s reload'
                # Add PING pkg … docker images tend to not have even `ping`, so must install
                    apt-get update && apt-get install -y iputils-ping  # Install ping; 
                # Hostname is container ID.
                    # E.g., redis server/client; access client @ server container
                    docker start $_CTNR               # redis-server
                    docker exec -it $_CTNR redis-cli  # redis-cli @ running redis-server container 
                # ENVIRONMENT VARs : View all 
                docker exec -it $_CTNR env
        # STOP (container)
            docker stop $_CTNR      # SIGTERM (politely, at first)
            docker kill $_CTNR      # SIGKILL (now)
            # stop ALL RUNNING containers 
            docker ps -q | xargs docker stop
            # stop ALL RUNNING containers per FILTER 
            docker ps | grep 'FILTER' | gawk '{print $1}' | xargs docker stop  
            dstop(){ [[ "$@" ]] && docker ps | grep "$@" | gawk '{print $1}' | xargs docker stop; }
        # COMMIT changes; image from container : BUILD a new image from an existing [running] container  
            # https://docs.docker.com/engine/reference/commandline/commit/
            docker commit [-c $_APPEND_DOCKERILE_COMMAND] $_CTNR # can be running ! 
            # … an IMPERATIVE equiv. to Dockerfile method of image builds 
                # Make changes from a shell launched into a running container, 
                # and then examine and commit those changes.
                docker exec -it $_CTNR /bin/bash
                # … do stuff in the container and then exit
                docker diff $_CTNR  #… examine changes
                docker commit $_CTNR $_REPO_NAME/$_TAG
        # SAVE the new image in a tarball to make it portable
            # for upload to any image registry.
            docker save -o $_IMG_NAME.tar $_REPO_NAME/$_TAG 
            #… Where $_REPO_NAME/$_TAG is just the image reference. 
            # E.g., gd9h/busybox.custom:v3.0.3
        # LOAD image tarball into any Docker Registry
            docker load < $tarballed.tar.gz         # Load from STDIN
            docker load -i $tarballed_image.tar     # Load from file
            docker tag $_IMG_ID $_REPO_NAME/$_IMG_NAME:$_TAG
        # RUN = [PULL] + CREATE + START  (NEW container) 
            docker run [OPTIONS] $_IMG [COMMAND] [ARG…]  # +Runs COMMAND @ container on start
            # https://docs.docker.com/engine/reference/commandline/run/ 
            docker run $_IMG          # run a new container & execute default CMD per Dockerfile
            docker run -d $_IMG       # detach; run @ BACKGROUND process; job
            docker run $_IMG COMMAND  # run and execute ADDITIONAL COMMAND therein
            docker run -it $_IMG bash # OVERRIDE default CMD; start container INTERACTIVELY; container terminates on exit;
                                      # Shells: bash|powershell|zsh|sh 
                                      # … CTRL+P+Q to EXIT & LEAVE pid 1 RUNNING
                -i  # --interactive; connect to STDIN of container; keep open even if not attached 
                -t  # --tty; allocate a pseudo-TTY
                -it # INTERACTIVE BASH SHELL @ container
                    # … CTRL-p CTRL-q to exit and LEAVE it RUNNING
                -d  # --detach; job; run as background process  
                --rm  # automatically remove container when it exits.
                # PUBLISH : map host to container PORT(s)/PROTOCOL(s) : 2 syntaxs
                    -p 8080:80/tcp -p 8080:80/udp  # host 8080 to ctnr 80; both TCP and UDP protocols 
                    # … EQUIVALENT …
                    -p published=8080,target=80,protocol=tcp -p published=8080,target=80,protocol=udp
                -p $hPORT:$cPORT  # --publish/BIND/EXPOSE; map HOST:CNTNR
                -p 7000-8000:7000-8000 # map an entire port-range
                -P  # --publish-all; publish/BIND/EXPOSE all exposed ports of container to random ports of host
                # Ports; publish/bind/expose a RANGE of ports …
                --expose=7000-8000  # expose to other containers on the bridge network.
                # List PORT MAPPINGs
                docker port $_CTNR [$cPORT[/$_PROTO]] # Sans ctnr port, lists ALL MAPPINGs
                #=> 80/tcp -> 0.0.0.0:8080
                #… app @ CTNR port 80, TCP protocol, accepting host connections from anywhere (0.0.0.0) at port 8080.
                --name $_NAME  # name the container; override default (random) name assignment  
                # NET-ALIAS (Round Robin) 
                --net-alias $_COMMON_DNS_NAME
                # NETWORK; Connect container to SPECIFIED network, e.g., host, rather than default  
                --network $_NTWK_NAME  # Ref: `docker network create --driver overlay $_NTWK_NAME`   
                --net $_NTWK_NAME      # Equivalent
                # Add hosts into your container's /etc/hosts file
                --add-host ${aNAME}:${_HOST_IP}   
                # @ docker-compose.yml 
                    extra_hosts:
                        - "${aNAME}:${_HOST_IP}"
                # E.g., 'host'; use host's network; not Docker's virtual
                --net host  # better performance, lower security
                # pass ENVIRONMENT VARIABLEs into container, but ONLY IF image build with its `ARG EnvName`
                -e  # --env 
                -e MYSQL_RANDPM_ROOT_PASSWORD=yes
                -e MYSQL_ALLOW_EMPTY_PASSWORD=yes
                # per FILE of such k=v pairs; the equivalent of `env_file` @ docker-compose (below)
                --env-file=FILE
            # Busybox : wget : HTTP response head of request @ IP:PORT 
             docker run -it busybox sh -c 'wget -qS -O - 172.17.0.2:80 |grep HTTP'
            # EX: run ctnr x detached (bkgnd proc); del ctnr on stop; 
            #     map host port 3000 to ctnr port 80; @ http://localhost:3000
                docker run --name 'x' --rm -d -p 3000:80 $_USERNAME/$_REPONAME:$_TAG   
            # Hello World;  https://hub.docker.com/_/hello-world/
                docker run hello-world  # Docker's "Hello World" container  
            # Alpine linux (5MB); pkg mgr is `apk`; INTERACTIVE SHELL (-it)
                docker run -it alpine          # Default CMD is `sh` (does NOT have bash)
                docker run -d alpine sleep 1d  # run detached; sleep for a day 
                #… KEEP ctnr ALIVE (running)
            # Ubuntu; login shell
                docker run -it ubuntu  # Default CMD is bash, so needn't specify
            # Nginx : Web Server a.k.a. Reverse Proxy Server  https://hub.docker.com/_/nginx/  
                docker run --name 'proxy' --rm -d -v "$(pwd)/wwwroot":/usr/share/nginx/html -p 8080:80 nginx  
                docker exec -it 'proxy' bash  # admin access/login 
            # Apache (interactive shell) 
                docker run --name 'httpd' --rm -dit -p 8080:80 -v "$(pwd)/src":/usr/local/apache2/htdocs/ httpd:2.4 
            # PHP CLI : run a PHP script and then terminate.
                docker run --rm -it -v "$(pwd)/src":/usr/src/app -w /usr/src/app php:7.2-cli php 'index.php' 
            # PHP @ Apache server 
                docker run --name 'php' --rm -d -p 8080:80 -v "$(pwd)/src":/var/www/html php:7.2-apache 
            # MySQL (server)
                docker run --name 'dbm' -d -p 3306:3306 -e MYSQL_RANDPM_ROOT_PASSWORD=yes mysql
                docker logs db | grep 'PASSWORD'  # … to get the generated password
            # Redis server/client; access client @ server container  https://hub.docker.com/_/redis  
                # Redis Server (redis-server) & bkgnd proc; accessible @ host port ${hPORT}
                docker run --name 'r1' -d redis
                # … +PERSISTENT data (volume @ host machine/dir); db accessible @ host port ${hPORT}
                docker run --name s'r1' --rm -p 6379:6379 -d redis redis-server --appendonly yes
                docker run --name s'r1' --rm -p 6379:6379 -v /${path_at_host}:/data -d redis redis-server --appendonly yes
                # @ Swarm 
                docker network create 'web' --driver overlay
                docker service create --name 'r1' -p 80:80 \
                    --network 'web' \
                    --replicas 2 \
                    'redis:3.2'
                # Redis CLI (redis-cli) @ redis server container "r1" 
                docker exec -it 'r1' redis-cli 
                docker run -it --network some-network --rm redis redis-cli -h 'r1'
            # Busybox 
                docker run busybox ls   
                docker run -it busybox sh  # interactive shell @ tty
            # Others 
                docker run -d -P training/webapp python app.py
                docker run -it -p 8080:80 wordpress  
            # Portainer 
                docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
                # /var/run/docker.sock is a Unix Socket; docker daemon listens; for daemon-to-ctnr comms
                # @ Swarm localhost:9000
                curl -L 'https://downloads.portainer.io/portainer-agent-stack.yml' -o 'portainer-agent-stack.yml'
                docker stack deploy -c 'portainer-agent-stack.yml' 'portainer'
            # Ruby box; a ruby-for-devs image; creates /app if not already exist
                docker run -it -v $(pwd):/app ruby:2.3 sh  
            # PostgreSQL Server : v12+ REQUIREs user/pass (`-e …`) else terminates
                docker run -d --rm --name $ctnr -p 5432:5432 \
                    -v $(pwd):/home \
                    -e POSTGRES_DB=${DB_NAME:-dbp} \
                    -e POSTGRES_PASSWORD=${DB_PASSWORD:-postgres} \
                    -e POSTGRES_USER=${DB_USER:-postgres} \
                    'postgres:12.6-alpine'
                # @ Swarm 
                docker service create --name 'db' \
                    --network 'backend' \
                    -e POSTGRES_HOST_AUTH_METHOD=trust \
                    --mount type=volume,source=db-data,target=/var/lib/postgresql/data \
                    'postgres:9.4'
                # @ Golang 
                    # cmd := exec.Command("docker", "run", "-P", "-d", "postgres:11.1-alpine")
                    # cmd.Run()
                # Client (psql) @ host (user:postgres, db:postgres)
                    psql -U postgres -h localhost [-p 5432 postgres]
                # Client (psql) @ container
                    docker exec -it 'db' bash -c "alias ls='ls -l' && cd /home && psql -U postgres" 
                # pgadmin4 GUI client (FAILs to connect)
                    docker run --name 'pgadmin' --rm -d -p 5555:80 -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" -e "PGADMIN_DEFAULT_PASSWORD=admin" dpage/pgadmin4 
            # Docker-for-Windows (DFW) VM shell access: 
                docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -i sh 
                docker run -it --rm --privileged --pid=host justincormack/nsenter1
                # Linux `nsenter` tool (util-linux pkg) provides access to the namespace of another process
        # UPDATE 
            docker update [OPTIONS] $_CTNR1 [$_CTNR2…]  
            #… live update; few options compared to SERVICEs @ SWARM; `docker service update…`
        # DELETE 
            docker container rm $_CTNR  # delete 1 container per name|id  
            docker rm $_CTNR            # delete 1 container per name|id; alias  
            # delete per (partial)name string (name of container, not image)
            docker ps -aq --filter name=STRING | xargs docker rm 
            # delete per IMAGE built from
            docker ps -a --filter ancestor=$_IMG | xargs docker rm 
            # delete all containers per FILTER 
            docker ps -a | grep 'FILTER' | gawk '{print $1}' | xargs docker rm
            drm(){ [[ "$@" ]] && docker ps -a | grep "$@" | gawk '{print $1}' | xargs docker rm; }
            # delete all containers 
            docker rm $(docker ps -aq) 
            docker container rm $(docker container ls -aq)
            # delete ALL containers AND build cache 
            docker system prune -f  
        # LOGs
            # CONTAINER/APP LOGs 
                # pid 1 process is captured and forwarded, 
                # so app should log to STDOUT & STDERR, 
                # or write to a log file @ mounted vol @ host.
                # +Logging Drivers; config @ Docker daemon.json
                docker logs $_CTNR     # fetchlogs of container 
                docker logs -f $_CTNR  # follow; live log @ RUNNING container, else full log
                docker container logs [-f] $_CTNR  # same/newer/canonical command  
            # ENGINE/DAEMON LOGs
                # @ systemd 
                    journalctl -u docker.service
                # else @  
                    /var/log/messages
                # @ Windows 
                    ~/AppData/Local/Docker 
        # TOP/STATS @ RUNNING CONTAINER 
            docker top $_CTNR         # TOP; process list
            docker stats --no-stream  
            # CTNR ID NAME CPU[%] MEM.USAGE/LIMIT[MiB] MEM[%] NET.I/O BLOCK.I/O PIDs
            # https://docs.docker.com/engine/reference/commandline/stats/
        # ENV VARs : List ALL environment variables set in an image, per GNU `env` cmd:
            docker run --rm $_IMG env 
        # INSPECT
            docker container inspect $_CTNR \
                --format '{{json .NetworkSettings}}' |jq .
    # NETWORKing : CLI Management
        # User Guide https://docs.docker.com/v17.09/engine/userguide/networking/  
        # Ref  https://docs.docker.com/network/
        # IANA https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
        # Swarm Networking Deep dive (2020) : https://docker-tutorial.schoolofdevops.com/swarm-networking-deepdive/
        # Docker isolates its containers in its own virtual private network,
        # connecting to the host network through a software bridge at its 'bridge' network.
        # 'bridge' is the default docker network and name of its driver.
        docker network inspect bridge # Docker's default network; bridges docker's VPN to host, 
        # and allows inter-container comms
        # @ Swarm mode, a second bridge, docker_gwbridge, handles that for the swarm.
        docker network inspect docker_gwbridge
        # Both bridge and  
        # DNS : 127.0.0.11 is Docker's embedded DNS server (always).
        # Adding DNS statement to YAML, declaring external DNS, solved Reverse DNS lookup issue @ SMTP svc.
        # https://docs.docker.com.zh.xy2401.com/v17.09/engine/userguide/networking/configure-dns/
        # DEFAULT PORTs 
            5432 # postgres
            # @ Swarm Mode 
            TCP 2376 # Swarm Control Plane (TLS); Docker's internal REST API; NEVER USE it.
            # REQUIRED : OPEN (public) PORTS/PROTO for comms between Docker Engines at each node in swarm:
            TCP 2377 # Swarm Commands; Docker Swarm RPC; CLUSTER MANAGEMENT per CLI.
            UDP 4789 # Swarm Data; overlay network (VXLAN); container ingress; DATA PATH default
            TCP 7946 # Swarm Node-to-node traffic; container network discovery
            UDP 7946 # Swarm Node-to-node traffic; container network discovery
            # @ Docker machine 
            TCP 3376 # Comms btwn local Docker client and remote Swarm Managers; to activate node, etc.
        # SHOW Docker Swarm cluster-management traffic
            tcpdump -v -i eth0 port 2377  
        # SHOW networks (drvrs: bridge, host, ingress, overlay) 
            docker network ls  # list all networks 
            docker network ls --filter drive=bridge
            docker network ls --format "{{.ID}} : {{.Driver}} : {{.Name}}"
        # INSPECT a network (JSON); incl. shows IP Address Management (IPAM) 
            ip addr|neigh|route  # @ container shell/session; docker exec -it $_CTNR sh
            ip route  # default is "the" IP; host IP as seen by container(s).
            # Such is the IP mapped from container to host (different context) per docker's NAT. 
            host=$(ip route | awk '/default/ { print $3 }')
            docker network inspect $_NTWK_NAME 
            # E.g., 
            docker network inspect 'bridge'  # The default private virtual network DRIVER …
                # "Subnet" : "172.17.0.0/16",
                # "Gateway": "172.17.0.1"
            docker network inspect 'web1' | jq -rc .[].IPAM.Config
                # [{"Subnet":"10.0.36.0/24","Gateway":"10.0.36.1"}]
        # CREATE network (default driver is 'bridge')
            docker network create [OPTIONS] $_NTWK_NAME  
            docker network create --driver=overlay --internal 'pvt1'
            # Create overlay with multiple subnets
            # Setting *static* CIDR and IP of service(s) !!! 
            # https://docs.docker.com/engine/reference/commandline/network_create/
            docker network create -d overlay \
                --subnet=192.168.10.0/25 \
                --subnet=192.168.20.0/25 \
                --gateway=192.168.10.100 \
                --gateway=192.168.20.100 \
                --aux-address="svc1=192.168.10.5" --aux-address="svc2=192.168.10.6" \
                --aux-address="svc3=192.168.20.5" --aux-address="svc4=192.168.20.6" \
                'dmz1'
            # Overlay networks  https://docs.docker.com/network/overlay/
            # OPTIONs  https://docs.docker.com/engine/reference/commandline/network_create/#options
        # DELETE network
            docker network rm $_NTWK_NAME 
            docker network prune  # remove ALL not in use (default networks preserved)
        # CONNECT/DISCONNECT 
            docker network connect|disconnect $_NTWK_NAME $_CTNR  # While running; add/remove NIC
            # COMMS BTWN TWO CONTAINERS : ping one from another 
            docker network connect 'bridge' c1 
            docker network connect 'bridge' c2
            docker exec -it c1 ping c2  # Test @ ping 
            PING c2 (172.19.0.2): 56 data bytes
            64 bytes from 172.19.0.2: seq=0 ttl=64 time=0.139 ms
    # PORTs 
        docker port $_CTNR  # List port mappings for the container
        docker inspect $_CTNR | jq '.[].NetworkSettings.Ports'
    # STORAGE : PERSISTENT STORAGE; stored OUTSIDE container; mounted as path at container  
        # TYPEs : Volume | Bind Mount | tmpfs  (volume|bind|tmpfs)
            # VOLUME : NAMED; stored @ host (running Docker Engine)  
                ls '/var/lib/docker/volumes/'${_VOL_HASH_OR_NAME}/_data
                # https://docs.docker.com/storage/volumes  
                -v foo:/app  # NAME:CNTNR_PATH  
                # CREATE (explicitly) https://docs.docker.com/engine/reference/commandline/volume_create/ 
                    docker volume create --label ULID=$(ulid) dbp1_data

                    docker volume create \
                        --label ULID=$(ulid) \
                        --opt type=tmpfs \
                        --opt device=tmpfs \
                        --opt o=size=100m,uid=1000 \
                        'foo'
                    # per Linux mount OPTions  http://man7.org/linux/man-pages/man8/mount.8.html
                    # @ SERVICEs, use the MOUNT SYNTAX, NOT `-v`
                        --mount "type=volume,src=${_VOL_NAME},dst=${_CNTNR_PATH},volume-driver=local,volume-opt=type=nfs,volume-opt=device=${_NFSserver}:${_NFSpath},volume-opt=o=addr=${_NFSaddress},vers=4,soft,timeo=180,bg,tcp,rw"  
                # CREATE an NFS Volume as a SERVICE  https://docs.docker.com/storage/volumes/#create-a-service-which-creates-an-nfs-volume
                    docker service create -d \
                        --name nfs-service \
                        --mount 'type=volume,source=nfsvolume,target=/app,volume-driver=local,volume-opt=type=nfs,volume-opt=device=:/var/docker-nfs,"volume-opt=o=addr=10.0.0.10,rw,nfsvers=4,async"' \
                        nginx:latest
                # LIST 
                    docker volume ls
                # INSPECT 
                    docker inspect volume VOLNAME
                    
                    # All : name, date
                    docker volume inspect $(docker volume ls -q)| jq -rM '.[] | .Name, .CreatedAt'

                # PRUNE (delete) ALL UNUSED volumes; vols with no associated container(s)
                    docker volume prune  
            # BIND MOUNT : ANY host dir|file mounted as specified path (at container)
                # https://docs.docker.com/storage/bind-mounts/  
                    -v "$(pwd)"/target:/app  # HOST:CNTNR (paths)
                    --volume "$(pwd)"/target:/app
                    --mount type=bind,src="$(pwd)"/target,dst=/app  
                # @ Windows : PATH SYNTAX …  
                    -v //c/target:/app
                    # … is a RUNTIME CONFIG; cannot build per Dockerfile; can per docker-compose.yml
                # Mount NFS using local driver (sans 3rd party driver)
                    # https://stackoverflow.com/questions/47756029/how-does-docker-swarm-implement-volume-sharing
                    # @ Create
                    docker volume create --driver local \
                        --opt type=nfs \
                        --opt o=nfsvers=4,addr=192.168.1.1,rw \
                        --opt device=:/path/to/dir \
                        foo
                    # @ Run
                    docker run -it --rm \
                        --mount type=volume,dst=/container/path,volume-driver=local,volume-opt=type=nfs,\"volume-opt=o=nfsvers=4,addr=192.168.1.1\",volume-opt=device=:/host/path \
                        foo
                    # @ Service
                    docker service create \
                        --mount type=volume,dst=/container/path,volume-driver=local,volume-opt=type=nfs,\"volume-opt=o=nfsvers=4,addr=192.168.1.1\",volume-opt=device=:/host/path \
                        foo
                    # @ YAML
                    volumes:
                        nfs-data:
                        driver: local
                        driver_opts:
                            type: nfs
                            o: nfsvers=4,addr=192.168.1.1,rw
                            device: ":/path/to/dir"

            # tmpfs MOUNT : host system-memory mounted as path at container.
                    --mount type=tmpfs,destination=/app
        # STORAGE DRIVERS
            # Volume Plugins  https://docs.docker.com/engine/extend/legacy_plugins/#volume-plugins
                # Rex-Ray https://github.com/rexray/rexray#runtime---docker-plugin 
                docker plugin install rexray/ebs \
                    EBS_ACCESSKEY=$access_key EBS_SECRETKEY=$secret_key 
            # @ Swarm  https://stackoverflow.com/questions/47756029/how-does-docker-swarm-implement-volume-sharing
    # INSPECT OBJECTs (IMAGE|CONTAINER|NETWORK|other)  
        # https://docs.docker.com/engine/reference/commandline/inspect/#extended-description
        docker inspect OBJECT     # Detailed (low-level) info (JSON)  
        docker inspect $_CTNR   
        docker volume inspect app_redis_data
        # FILTER per Golang `--format`, OR `jq` where "[]" is all els; "[0]" is first index
docker-compose       # tool @ Dev only    
# https://docs.docker.com/compose/reference/overview/
docker-compose.yml   # YAML @ Dev + Prod
    # https://docs.docker.com/compose/compose-file/
    # CHEATSHEET: https://gist.github.com/jonlabelle/bd667a97666ecda7bbc4f1cc9446d43a 
# Docker Compose : CLI tool + YAML task file 
    # DEV TOOL; define/run multi-container Docker apps, declaratively, per YAML file. 
    'docker-compose.yml'  # DEFAULT fname, else use `-f PATH`
    docker-compose [-f 'foo.yml'] {up|down} 
    # if no YAML specified, then ALL docker-compose[-XXX].yml @ root are launched
    docker-compose up            # `docker run IMAGE`; tags per `services:` name(s) @ YAML
    docker-compose up --build    # `docker build . && docker run IMAGE`
    docker-compose up -d         # as bkgnd process
    docker-compose down          # all down @ project dir
    docker-compose down -v       # delete volumes too
    docker-compose stop          # stop container 
    docker-compose kill          # kill container 
    docker-compose logs [-f]     # view logs [--follow; keep watching]
    docker-compose top           # display running processes
    docker-compose ps            # list containers
    docker-compose build         # build image
    docker-compose down --rmi local  # delete local images too

    # Run command INSIDE container 
    docker-compose exec $_SERVICE_NAME $_COMMAND  
    # Shell into a PHP container: 
    docker-compose exec php-fpm bash 
    # Run a Symfony console:
    docker-compose exec php-fpm bin/console 
    # Open a MySQL shell
    docker-compose exec mysql mysql -uroot -pCHOSEN_ROOT_PASSWORD

    # Maintenance
        # RESTART POLICIES: no|always|on-failure|unless-stopped
            node-app:           # YAML
                restart: "no"   # strings require quotes, else may interpret (boolean)
    # NETWORK
        # create network called `appnet`
        networks:
            appnet:
        # join  preexisting network; create per docker network 
        networks:
            foonet:
                external: true      # Created already; `docker network create …`
    # VOLUMEs  
        # https://docs.docker.com/compose/compose-file/#volumes  
            …  
            volumes:  
              - type: volume
                source: mydata       # @ host docker engine
                target: /data        # @ container 
                volume:
                    nocopy: true     # No copy on create
                        
              - type: bind
                source: ./static     # @ host FS
                target: /app/static  # @ container 
        …
        volumes:
            mydata:
                external: true       # Created already; `docker volume create mydata`
    # ENVIRONMENT 
        # Inject the local environment into Docker container and service  
        env_file:
        # https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file
        # `environment:` section OVERRIDEs declarations herein.
          - ./common.env
          - ./apps/web.env
          - /opt/runtime_opts.env
        #… IGNORED @ `docker stack`.

            #… The *.env FILE(s) contain the `KEY=VAL` list; one per line:
            VAR1=1
            VAR2="true"

        environment:
        # https://docs.docker.com/compose/compose-file/compose-file-v3/#environment
        # OVERRIDES env_file DECLARATIONs
        # If key only, then resolvs to OS Environment value
          - APP_DB_DISABLE_TLS=1
          - APP_AUTH_PRIVATE_KEY_FILE=${_APP_AUTH_PRIVATE_KEY_FILE}
          - APP_DB_USER=${_DB_USER}
          - APP_DB_PASSWORD
          #… Some downstream processes, apps such as MySQL and PostgreSQL, 
          # use *_FILE namespace to trigger file mode handling of an environment variable.
          # Golang's os.Getenv("FOO") reads the variable value as a string regardless of variable name.

    # SWARM
        # 2 MODEs
            # 1. Single-host SINGLE NODE (Single-host MODE); sans docker-machine; client configured to local engine 
            # 2. CLUSTER (Multi-host MODE); Multiple VMs, each running a docker engine, all acting as one; 
            #    See "REF.Docker.Get-Started{.md|.html}" 
        # https://docs.docker.com/engine/reference/commandline/swarm/  
        # One active MASTER node (VM); all others WORKERS (MINIONS)
        # (NOT REQUIRED for services @ docker-compose)
            docker swarm init|join|join-token|leave|update|unlock|unlock-key  
            docker swarm leave --force  # Useful @ single-host mode (@DfW)
            # VERIFY Engine is in Swarm mode
            docker info |grep Swarm  #=> Swarm: active
        # ACTIVATION, per `docker swarm init`, ENABLES ADDITIONAL COMMANDS:
            docker node|service|stack|secret  
        # NETWORK : Overlay : https://docs.docker.com/network/overlay/
        # Swarm Networking  : https://docs.docker.com/engine/swarm/networking/
        # Swarm Networking Deep dive (2020) : https://docker-tutorial.schoolofdevops.com/swarm-networking-deepdive/
            # DO NOT CREATE overlay network(s) UNTIL swarm MODE INITIALIZED.
            docker network create --driver=overlay 'web1'
            docker network ls                 # List all networks
            docker network inspect 'overlay'  # Inspect the (default) overlay network
            # Routing Mesh (ingress)  https://docs.docker.com/engine/swarm/ingress/  
                # Customize:  https://docs.docker.com/engine/reference/commandline/network_create/#network-ingress-mode
                # All nodes participate in an ingress routing mesh. The routing mesh enables each node in the swarm to accept connections on published ports for any service running in the swarm, even if there’s no task running on the node. The routing mesh routes all incoming requests to published ports on available nodes to an active container.
            # Overlay network (VXLAN); connects all swarm nodes  https://docs.docker.com/network/overlay/
                # A distributed network among multiple Docker daemon hosts. This network sits on top of (overlays) the host-specific networks, allowing containers connected to it (including swarm service containers) to communicate securely when encryption is enabled. Docker transparently handles routing of each packet to and from the correct Docker daemon host and the correct destination container. Overlay Network Tutorial:  https://docs.docker.com/network/network-tutorial-overlay/ 
            docker network inspect 'tor_web' #… created custom overlay (instead of 'overlay').
                {
                    "Name": "tor_web",
                    ..
                    "Scope": "swarm",
                    "Driver": "overlay",
                    "EnableIPv6": false,
                    "IPAM": {
                        "Driver": "default",
                        "Options": null,
                        "Config": [
                            {
                                "Subnet": "10.0.100.0/24", # Default: "10.0.8.0/24"
                                "Gateway": "10.0.100.1"    # Default: "10.0.8.1"
                            }
                        ]
                    },
                    "Internal": false,
                    "Attachable": false,
                    "Ingress": false,
                    "ConfigFrom": {
                        "Network": ""
                    },
                    "ConfigOnly": false,
                    # @ Stack down: 
                    "Containers":{} 
                    # @ Stack up:
                    "Containers": {
                        "23257e48cc1d77e14610bc54590d28c4662c40c2298221df34b411cc9cbb69a1": {
                            "Name": "tor_api.1.42dt0e0h9cb8j04fs0aiiqox8",
                            "EndpointID": "a73357d3b1a7a7dcce6580bf074c0efa1ee9dd9da4ada49aa72a69bdee94ec3d",
                            "MacAddress": "02:42:0a:00:64:03",
                            "IPv4Address": "10.0.100.3/24",
                            "IPv6Address": ""
                        },
                        "2f9fbc55548d98cc215d5dd31ad66aac29034b8db2271947d8ce258d292b6582": {
                            "Name": "tor_ngx.1.u4b1ftj9c6cd07rrvfc1b2d80",
                            "EndpointID": "dcd0a6b24c3d80e7157353f2fe89d80ee5d7a2bb3183a418625bb40cfec6d807",
                            "MacAddress": "02:42:0a:00:64:0a",
                            "IPv4Address": "10.0.100.10/24",
                            "IPv6Address": ""
                        },
                        "422f01ad2a53c436265a6d20014c706258886ea2244a154f048c389ae7fdcd9a": {
                            "Name": "tor_tor.1.jvowmkav7zliin14ctnb7ecja",
                            "EndpointID": "34126828bba34871feac61dc2108f806ba80c12e4f7654f686182f02ca487b7c",
                            "MacAddress": "02:42:0a:00:64:06",
                            "IPv4Address": "10.0.100.6/24",
                            "IPv6Address": ""
                        },
                        "4e914ca025c0ccb45342a61e64d53a587025bef675f951430fabfa9ae39b1707": {
                            "Name": "tor_soc.1.z56oi49gp6n3v6xw41m6rzac9",
                            "EndpointID": "8703e24c8561ec760b50fa7107fbc900d944cb9292a86e7a4e81e3a67d03764b",
                            "MacAddress": "02:42:0a:00:64:08",
                            "IPv4Address": "10.0.100.8/24",
                            "IPv6Address": ""
                        },
                        # The load balancer IP is client IP (10.0.100.4) seen by (Golang) app server.
                        # Docker issue: client's Real IP is not visible.
                        "lb-tor_web": {
                            "Name": "tor_web-endpoint",
                            "EndpointID": "7aa3fc0eddda88d9df39bc7e6f118d8e6a63a430b6b56bc0d5fac5faaf0342e0",
                            "MacAddress": "02:42:0a:00:64:04",
                            "IPv4Address": "10.0.100.4/24",
                            "IPv6Address": ""
                        }
                    },
                    "Options": {
                        "com.docker.network.driver.overlay.vxlanid_list": "4136"
                    },
                    "Labels": {
                        "com.docker.stack.namespace": "tor"
                    },
                    # Peers are swarm NODE(s) Name(s) and IP(s) 
                    "Peers": [
                        {
                            "Name": "c88e0f32cd1d",
                            "IP": "192.168.65.3"
                        }
                    ]
                }
            # Bridge driver options  https://docs.docker.com/engine/reference/commandline/network_create/#bridge-driver-options  
            # EXAMPLE: Start a service and then REPLACE its existing overlay network (nwkA) WITH NEW (nwkB)
                # Create a service (having default-driver network)
                docker service create \
                    --name 'ngxSvc' \
                    --publish target=80,published=80 \
                    --replicas=5 \
                    --network 'nwkA' \
                    'nginx'
                # Update a service : Replace nwkA with nwkB (having overlay-network driver)
                docker network create -d overlay 'nwkB'
                docker service update \
                    --network-add 'nwkB' \
                    --network-rm 'nwkA' \
                    'ngxSvc'
            # Public Network
                NET_DMZ1='web1'
                docker network create --driver=overlay ${NET_DMZ1}
            # Private Subnet 
                # Define params
                NET_PVT1_NAME='pvt1'
                NET_PVT1_ADDR='10.0.200'
                NET_PVT1_GTWY='10.0.200.1'
                NET_PVT1_CIDR="${NET_PVT1_ADDR}.0/24"
                # Create network
                docker network prune -f
                docker network create --driver=overlay \
                    --attachable --internal \
                    --subnet=${NET_PVT1_CIDR} \
                    # Gateway is NOT AVAILABLE @ compose (YAML)
                    --gateway=${NET_PVT1_GTWY} \
                    ${NET_PVT1_NAME}
                # Validate
                docker network ls
                docker network inspect ${NET_PVT1}
                #… Place reverse proxy on web1; app(s) and data store(s) on pvt1 (protected subnet)
            # Bridges : sans Swarm there is only docker0
                brctl show # To get $vx_lan_name; apt-get install bridge-utils
                bridge fdb show dev $vx_lan_name
                docker network inspect bridge # docker0 : 172.17.0.1
                    #=> "IPAM": { "Config": [ {"Subnet": "172.17.0.0/16", "Gateway": "172.17.0.1" }], …
                # IPAM (IP Address Management) PARAMs are SETTABLE @ YAML
                # https://docs.docker.com/compose/compose-file/#ipam
            # Docker Swarm cluster-management traffic
                tcpdump -v -i eth0 port 2377  
            # INGRESS : PUBLSISH PORTs : ROUTING MESH NETWORK --publish-add
            # http://docs.docker.oeynet.com/engine/swarm/ingress/
            # https://docs.docker.com/network/overlay/#customize-the-default-ingress-network
            # The swarm nodes can reside on a private network that is accessible to the proxy server, but that is not publicly accessible.
                docker service update \
                    --publish-add <PUBLISHED-PORT>:<TARGET-PORT> <SERVICE>
            # ENCRYPT the DATA PLANE  https://github.com/docker/labs/blob/master/networking/concepts/11-security.md
            docker network create --driver 'overlay' --opt 'encrypted' 'webnet'
                ```yml (equivalent)
                networks:
                    webnet:
                        driver: overlay  
                        driver_opts:
                            # Encrypt data plane
                            encrypted: "" 
                ```
            # ENCRYPT ingress network  https://docs.docker.com/engine/swarm/ingress/
            # Traefik https://blog.cepharum.de/en/post/install-traefik-in-docker-swarm.html?page_n18=2 
            docker network create --ingress --driver overlay --opt encrypted ingress
                # optionally … defining its subnet explicitly:
                    --subnet 10.10.0.0./16 ingress
        # MACHINE VM (NODE) CONFIGURATOR
            # PER CLOUD PROVIDER; a Docker install script (See https://get.docker.com)  
                curl -fsSL https://get.docker.com/ | sh  # one liner, or …
                curl -fsSL https://get.docker.com -o get-docker.sh  # @ the VM's shell
                sh get-docker.sh  # perhaps validate/inspect first ?!?!?!
            # PER DOCKER TOOL; `docker-machine` 
                # ISSUE: "boot2docker.ISO" v18.09 BREAKS ingress/overlay NETWORK, 
                # so explicitly/imperatively …  
                    docker-machine create -d hyperv \
                        --hyperv-virtual-switch "External-GbE" \
                        --hyperv-boot2docker-url "https://github.com/boot2docker/boot2docker/releases/download/v18.06.1-ce/boot2docker.iso" \
                        $_VM  
                # FIXed @ 2019?  https://github.com/docker/docker.github.io/issues/7780#issuecomment-469022882  
            # INSPECT
                docker-machine inspect $_VM
            # CONFIG, per VM; ip, image (iso) path, cert paths, etc.
                ~/.docker/machine/machines/$_VM/config.json
                #… escaped paths @ Win (C:\\foo\\bar)   
                ls ~/.docker/machine/machines/m1 # config + certs 
                # total 1038256
                # drwxr-xr-x 1 x1 x1       4096 Dec 17  2018 m1
                # -rwxr--r-- 1 x1 x1   50331648 Dec 17  2018 boot2docker.iso
                # -rwxr--r-- 1 x1 x1       1025 Dec 17  2018 ca.pem
                # -rwxr--r-- 1 x1 x1       1066 Dec 17  2018 cert.pem
                # -rwxr--r-- 1 x1 x1       2611 Feb  2  2019 config.json
                # -rwxr--r-- 1 x1 x1 1012809728 Feb  2  2019 disk.vhd
                # -rwxr--r-- 1 x1 x1       1671 Dec 17  2018 id_rsa
                # -rwxr--r-- 1 x1 x1        381 Dec 17  2018 id_rsa.pub
                # -rwxr--r-- 1 x1 x1       1679 Dec 17  2018 key.pem
                # -rwxr--r-- 1 x1 x1       1679 Dec 17  2018 server-key.pem
                # -rwxr--r-- 1 x1 x1       1094 Dec 17  2018 server.pem
        # CONFIGURE local docker client to remote (VM) docker engine (@ currrent SHELL only):
            # @ Bash 
            docker-machine env $_VM 
            # @ PowerShell 
            & docker-machine env $_VM | Invoke-Expression 
            #… Sets env vars and shows the command to run thereafter.
            #… Running the instructed command thereafter configures LOCAL docker CLIENT to REMOTE (VM) docker ENGINE:
                docker node ls                           #… instead of `docker-machine ssh $_VM "docker node ls"`
                docker stack deploy -c ${_YAML} ${_APP}  #… locally deploy; local file(s); remote engine.
            # MUCH SIMPLER than wrapping all such commands to run @ swarm leader node … 
            docker-machine ssh $_VM "docker node ls" #… moreover, YAML file(s) needn't be uploaded to VM.
        # UNCONFIGURE (RESET docker client to its local-host engine):
            docker-machine env --unset  #… resets the env vars; thence run the instructed command.
        # SSH into VM 
            docker-machine ssh $_VM
            ssh -i ~/.docker/machine/machines/${_VM}/id_rsa docker@192.168.1.15 
            #… test @ hyperv machine
        # INIT/TEST
            docker info | grep Swarm   #=> "Swarm: (in)active"
            docker swarm init                 # Activate Swarm Mode
            docker node|service|stack|secret  # ADDITIONAL `docker` COMMANDS enabled upon Swarm Mode activation.
        # IP 
            docker-machine ip $_VM            # Get the private IP Address of the machine 
        # INIT/JOIN; Activate Swarm Mode; 
        # regardless of VM configurator (docker-engine, cloud proivder, or otherwise) 
            docker swarm init [--advertize-addr] # if more than one interface, then advertize-addr REQUIRED
                # Autolock; prevents restarted mgrs from auto join swarm; prevents reversion to prior state
                --autolock  
                # Outbound Swarm Manager traffic:
                --advertise-addr IP|INTERFACE[:PORT]  # Node-to-node comms; advertise API-access address.
                    # MUST SET IF host has MULTIPLE interfaces …
                        # Private IP Address okay even for cross-vendor swarms 
                     ip -4 addr show dev eth0 #=> e.g., 172.29.148.53
                --advertise-addr 'eth0:2377'  # USE interface instead : DO NOT NEED PORT (is always 2377)
                # Inbound Swarm Manager traffic:
                --listen-addr IP|INTERFACE[:PORT]  # DEFAULT is 0.0.0.0:2377
                --listen-addr 'eth0:2377'
                # Optionally override DATA PATH; must be within 1024 - 49151
                --data-path-addr='eth1' # separates DATA TRAFFIC from swarm mgmt traffic; v1.31
                # Get Leader's PUBLIC IP address
                LEADER_IP=$(docker-machine ip $_VM) 
            # TOKENs are generated per …
                "SWMTKN-1-${_PER_CLUSTER}-${_AS_MGR|_AS_WKR}"
        # JOIN as TYPE (manager|worker)  
            docker swarm join --token ${_TOKEN}
            # @ VM (join as manager)
                docker swarm join \
                    --advertise-addr "${_THIS_VM_IP_OR_ADAPTER}:2377" \
                    --token ${_MGR_TOKEN} \
                    "${_SWRM_MGR_IP_OR_ADAPTER}:2377" 
                    #… ALWAYS use port 2377, or don't specify. 
            # @ HOST 
                docker-machine ssh $_VM "docker swarm join --token ${_TOKEN} ${_SWRM_MGR_IP}"  
        # GET join-token (JOIN-AS token); per TYPE (manager|worker)  
            docker swarm join-token [manager|worker] [-q]  # `-q` returns token only;
            #… sans `q`, command returns the JOIN CMD +info 
                _MGR_TOKEN=$(docker swarm join-token -q manager)
                _WKR_TOKEN=$(docker swarm join-token -q worker)
        # PROMOTE : Role of Manager/Worker can be changed per `node` command:
            docker node promote $_VM  # promote a Worker to Manager ("Reachable", not "Leader")  
        # ROTATE JOIN-TOKEN 
            docker swarm join-token --rotate worker  
        # CERT
            sudo openssl x509 -in /var/lib/docker/swarm/certificates/swarm-node.crt -text 
            # SET CERT ROTATION INTERVAL 
            docker swarm update --cert-expiry 48h
        # LOCK the SWARM (AUTOLOCK)  
            docker swarm init --autolock         # @ init 
            docker swarm update --autolock=true  # @ update
            # .. Save the unlock-TOKEN
        # UNLOCK (e.g., on Engine restart) 
            service docker restart  # Docker engine restart (just for reference)
            docker swarm unlock     # Queries for unlock-token
        # LEAVE swarm  (Must run @ EACH NODE)
            docker swarm leave          # remove Worker node; must do @ each node of the swarm 
            docker swarm leave --force  # Remove Manager node; -f, --force
        # START/STOP/REMOVE VMs
            # @ host, per PS for-loop
            PS> for($i=1; $i -le 3; $i++){docker-machine start|stop|rm "vm$i"}   
        # NODE commands (only for VMs joined into swarm; all others are invisible)
            docker node ls|ps|rm|inspect|update|promote|demote
            # LIST NODEs
                docker node ls --filter role=manager
                docker node ls --filter role=worker 
            # UPDATE https://docs.docker.com/engine/reference/commandline/node_update/
                # Do drain then pause before shutting down a swarm node; seen as "Down"
                docker node update [OPTIONS] NODE
                    --availability active|pause|drain
                    --label-add key=value    # Add or update label
                    --label-rm foo           # Remove label
                    --role worker|manager
                docker node update --label-add "$k1=$v1" --label-add "$k2=$v2" $NODE_NAME


        # @ CMD 
        docker OBJECT update [OPTIONS] OBJ_NAME
        # @ YAML 
            labels: # Array
                com.example.description: "Accounting webapp"
                com.example.department: "Finance"
                com.example.label-with-empty-value: ""
            # OR
            labels: # Dictionary 
                - "com.example.description=Accounting webapp"
                - "com.example.department=Finance"
                - "com.example.label-with-empty-value"

                # PAUSE / STOP a node (VM) without removing it from the swarm
                    docker node update --availability drain $_VM
                    docker node update --role worker $_VM  #… optionally
                    docker node update --role pause $_VM
                # UPDATE role of Worker; promote to Manager; "Reachable" not "Leader"
                    docker node update --role manager $_VM
                # UPDATE : NODE LABELs (for SERVCE CONSTRAINTs)
                    docker node update --label-add 'data-drive=ssd' 'vm2'
            # INSPECT 
                docker node inspect 'h1' --pretty 
            # LIST all NODEs (VMs) of (JOINED into) the CLUSTER
                docker node ls \
                    --format "table {{.ID}}\t{{.Hostname}}\t{{.Status}}\t{{.Availability}}\t{{.ManagerStatus}}"
            # LIST ALL Tasks of ALL Services across ALL Nodes
                docker node ps $(docker node ls -q) \
                    --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}" \
                    | uniq | grep -v Shutdown
                #… to find the node running a service/container
                #… container NAMES are of: `<STACK>_<SVC>.<TASK#>.<TASK_ID>`, e.g., 'app_rds.1.f0pd8lcif0m433yp6h0iqpgzp'  
            # CONNECT (SSH) TO a node (VM named 'h3') running a container 
                docker-machine ssh 'h3'
                #… Thereof, connect and execute the Redis client, `redis-cli`
                    docker exec -it 'app_rds.1.f0pd8lcif0m433yp6h0iqpgzp' redis-cli  #=> 127.0.0.1:6379>
        # SERVICEs : Manage services; app components are deployed as services. 
            docker service create|scale|update|rollback|ls|ps|logs|inspect|rm 
            # A service is composed of ALL container instances on ALL nodes running the same image. 
            # Services are components of the app; each service comprising a component thereof.  
            # Unique Names & IDs per: NODE(s), SERVICE(s), TASK(s), and CONTAINER(s) thereof. EACH. 
                _APP  = <STACK>             # stack of app components, deployed as services. 
                _SVC  = <STACK>_<SERVICE>   # if service created per STACK, then service-name format is "APP_SERVICE". 
                _CTNR = <STACK>_<SERVICE>.<TASK#>.<CTNR>
                # TASK(s)
                    # A task is 1 container running in 1 service; each task (container) is given a unique ID. 
                    # Task IDs increment from 1 to N, where N is total number of containers running that task. 
                    ${_SVC}.n  # is nth task (1 container) running the service named ${_SVC}.  
            # CREATE : across nodes, connected thru overlay network; APPs run per SERVICE(s) 
                # https://docs.docker.com/engine/reference/commandline/service_create
                docker service create [OPTIONS] $_IMG [COMMAND] [ARG…]
                # E.g., Create a service to ping google.com
                docker service create alpine ping www.google.com
                # E.g., more generally, with options
                docker service create --name $_SVC --replicas 3 --publish 8080:80 $_IMG 
                # BIND MOUNT 
                    --mount type=bind,source=${HOST_ASSETS},destination=/app/assets
                # VOLUME (persists @ HOST)
                    --mount type=volume,source=foo_bar,destination=/app/data,volume-label="color=red",volume-label="shape=round" 
                # SERVICE CONSTRAINTs (per NODE LABELs)
                docker service create --constraint 'node.labels.data-drive==ssd' …
                # E.g., 
                docker service create alpine ping 8.8.8.8  # unnamed, so ${_SVC} is service ID or its assigned (randomized) name
                # E.g., @ Swarm Cluster (uses overlay network)
                docker service create --name ${_SVC} [OPTIONS] --network ${_OVERLAY} $_IMG [COMMAND] [ARG…]
                # E.g., ElasticSearch; @ ssh session @ any node, `curl localhost:9200` reveals load-balancing
                docker service create --name esearch --replicas 3 -p 9200:9200 elasticsearch:2
                # E.g., nginx
                docker network create --driver overlay 'proxynet'
                docker service create --name 'proxy' --replicas 3 --network 'proxynet' -p 80:80 nginx:1.15.7 
            # UPDATE : deletes container(s) and launches new ones, as necessary to meet desired state  
                # Many `update` options are just `create` options with `-add` or `-rm` appended 
                docker service update [OPTIONs] ${_SVC}  # OPTION `-d`; `--detach {true|false}`; default is false; @ bkgrnd if true 
                # E.g., (can combine several options per cmd)
                docker service update --image= $_IMG:TAG ${_SVC}   # UPDATE $_IMG (most common update)
                docker service update --replicas 3 ${_SVC}         # SCALE up
                docker service update --secret-rm ${_SVC}          # REMOVE a SECRET
                docker service update --env-add NODE_ENV=prod      # ADD env var 
                … --publish-rm 8088 --publish-add 9090:80 …    # CHANGE (-rm/-add) host PORT; note syntax  
                # Updating a service REBALANCEs its TASKs across the swarm, so `--force` … 
                docker service update --force ${_SVC}  # DO IF, e.g., NODES ADDED without any change to the service
            # SCALE 
                docker service scale ${SVC1}=5 [${SVC2}=3] # number of REPLICAS; multiple services per cmd 
            # ROLLBACK 
                docker service rollback ${_SVC}
            # REMOVE 
                docker service rm ${_SVC}
                # then watch … 
                docker container ls [-q] # … repeate cmd until all removed; `-q` for ID only 
            # LOGs of SERVICEs (new feature)
                docker service logs ${_SVC}  # logs of a service of the app (swarm)
            # LIST all SERVICE(s)
                docker services ls
                watch docker service ls  
                # … watch is installed on Ubuntu; repeats command every 2 sec  
            # LIST all TASK(s) of a SERVICE; @ container(s) 1-N
                docker service ps ${_SVC}  # list swarm service
                # LIST container(s); equivalent(s) thereof; NOTE all (sans swarm) docker commands still work!
                docker container ls 
                # REMOVE a CONTAINER from a SERVICE; imperative, for test/dev
                docker container rm -f ${_SVC}.${_N}.${_TASK_ID}
            # LIST TASKs (containers 1-N) per SERVICE 
                docker service ps ${_SVC}    # list TASKs (containers) of SERVICE
                docker service ps "${_SWARM}_${_SVC}" 
                    -f KEY=VALUE  # filter; useful when "ambiguous"
                    --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"
            # LIST TASKS per NODE(s); defaults to current node (typically Master)
                docker node ps [ $_VM1|$_NODE_ID [$_VM2 …] ] 
                    -f KEY=VALUE  # filter; useful when "ambiguous"
                    --format "table {{.ID}}\t{{.Hostname}}\t{{.Status}}\t{{.Availability}}\t{{.ManagerStatus}}"  
            # PRUNE docker objects across all nodes in a Swarm cluster 
                #… bind mount path, /var/run/docker.sock, FAILs @ Windows (MINGW64)
                docker service create \
                    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
                    --mode=global \
                    --restart-condition on-failure \
                    docker docker system prune -af  # Alt. use smaller image: alpinelinux/docker-cli
        # STACKs (APPs) : PRODUCTION tools and environment, SANS docker-compose
            # https://docs.docker.com/engine/reference/commandline/stack/
            _SVCname=${_APP}_${_SVC} # Swarm and Stack-object names are namespaced: 
            #… <SWM_NAME>_<SVC_NAME> or <STACK_NAME>_<SVC_NAME>
            _TASK=${_SVCname}.n      # is nth task running a service 
            # DEPLOY : Create/Update a stack of services TO a SWARM  
                docker swarm …      # Swarm required for `docker stack`  
                docker stack deploy -c ${_YAML} ${_APP}  # options for K8s orch/config  
                docker stack deploy --prune -c …        # remove PRIOR constructs
                # NOTE: swarm / stack ignore 'docker-compose.yml' directives that utilize the host filesystem.
                # So, for example, `build:` directives (@ YAML) are ignored; build prior to 1st run of swarm/stack
                # per `docker build …`, or `docker-compose up …`.
            # LIST …
                docker node|stack|service ls         # List running NODE|STACK|SERVICE
                docker service ps ${_SVCname}    # List ALL TASKs (ALL containers @ ALL nodes)
            # TEAR DOWN the STACK/APP 
                docker stack rm ${_APP}
            # Summary of STACK commands
                docker stack deploy -c ${_YAML} ${_APP}  # Deploy per manifest (YAML)
                docker node|stack|service ls         # List running NODE|STACK|SERVICE
                docker node ps $(docker node ls -q) | uniq  # ALL TASKS of ALL CONTAINERS of SWARM
                docker stack ps ${_APP}              # LIST TASKs of ALL SERVICEs
                docker stack services ${_APP}        # List SERVICEs, desired/actual REPLICAS
                docker service ps ${_SVCname}        # List Replicas of service (@ all nodes)
                docker service logs ${_SVCname}      # List service logs
                docker inspect ID                    # Inspect (JSON) SERVICE|TASK|CONTAINER per ID
                docker inspect ${_SVCname}           # Inspect (JSON) SERVICE per NAME
                docker container ls -q               # List CONTAINERs (@ this Leader Node), IDs only
                docker ps -q                         # List CONTAINERs, IDs only (alias)
                docker stack rm ${_APP}              # Tear down an app
                docker service scale ${_SVCname}=2   # Reset number of replicas (ctnrs) of a service
            # YAML : STACKs (Compose file v3.0+) 
                # DEPLOY : Docker Samples @ GitHub  https://github.com/dockersamples
                    docker stack deploy -c ${_YAML} ${_APP}
                # LIST … 
                    docker stack ls
                    docker stack ps ${_APP}
                    docker stack services ${_APP}
                # LIST ALL TASK(s) 
                    # per STACK
                        docker stack ps "${_APP}" \
                            --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"
                            --filter KEY=VALUE  # -f; filter; useful when "ambiguous"
                            # FILTERing KEYs:  id, label, name, role, membership   
                            # https://docs.docker.com/engine/reference/commandline/node_ls/#filtering
                            --no-trunc --format "{{.Error}}"  # Read full ERROR MSGS 
                    # per SERVICE
                        docker service ps "${_SVCname}" \
                            --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"
            # @ OBJECTs (config, secret) SOURCE(s) : FILE(s) 
                # - Sans file uploads; use locally-hosted file; source is required ONLY @ DEPLOY;
                #   once the stack/service is running, the source may be removed or otherwise inaccessible.
                # - CANNOT re-up if source is MODIFIED; must cycle the service (down and then up again);
                #   workaround is to version the source names, e.g., cfg_0_1_1.
            # CONFIGs : per service : DISTRIBUTED IMMUTABLE k:v : stored @ ALL MANAGER nodes 
                # STRING <= 500 kb   : Available at ALL SERVICEs so declared. 
                # to store non-sensitive info, e.g., config files, in swarm, outside any image/containers.
                # https://docs.docker.com/engine/swarm/configs/
                docker config create|inspect|ls|rm
                # SOURCE is KEY name @ Docker client (docker); TARGET is file @ CTNR
                export _KEY='ngx_conf_v1'
                docker config create $_KEY "$(pwd)/assets/.env/nginx.conf" #… per KEY and source file
                docker config ls
                export _CTNR_TARGET='/etc/nginx/conf.d/default.conf'
                docker service create --config source=$_KEY,target=$_CTNR_TARGET
                docker config inspect $_KEY
                # ROTATE CONFIG(s) without taking down a service, yet KEEP the same TARGET (file):
                    export _KEY_v2='ngx_conf_v2'
                    docker service update \
                        --config-rm $_KEY \
                        --config-add source=$_KEY_v2,target=$_CTNR_TARGET \
                        $_SVC
                # YAML
                    version: "3.7"
                    # FILE SOURCE (file: ) may be LOCAL even if service node is remote.
                    # Alternatively, create per external method, and declare that here.
                    configs:
                        rds_v1_1_2:
                            file: ./rds_v1.1.2.txt
                        foo_v0_2_1:
                            external: true
                    services:
                        rds:
                            user: "${_UID}:${_GID}" 
                            configs: # LONG syntax (Note queer indent required; explains 2-space indent std.)
                                - source: rds_v1_1_2
                                  target: /mnt/app/redis_config
                                  uid: '103'
                                  gid: '103'
                                  mode: 0440
                                  #… if mismatch wrt UID:GID, then make WORLD READABLE (mode 0444)
                            …
                        foo:
                            …
                            configs: # SHORT syntax
                                - foo_v0_2_1
                                #… mounted @ '/foo_v0_2_1'  
                            …
            # SECRET : per service : DISTRIBUTED IMMUTABLE k:v : stored @ ALL MANAGER nodes 
                # STRING <= 500 kb  : Available (mounted/DECRYPTED) at ALL SERVICEs so declared. 
                # Like config, but encrypted when unmounted; outside of any service(s) using it.
                docker secret create|ls|inspect|rm 
                # Use ONLY @ SWARM/STACK, NOT docker-compose; INSECURE @ docker-compose.
                # E.g., Nginx TLS Certs/Keys 
                # https://docs.docker.com/engine/swarm/configs/#advanced-example-use-configs-with-a-nginx-service
                # https://docs.docker.com/engine/swarm/secrets/  
                # A secret's DEFAULT MOUNT POINT:
                    /run/secrets/<SECRET_NAME>     # @ Linux CTNR; tmpfs; in-memory storage. 
                    "%ProgramData%\Docker\Secrets" # @ Windows CTNR, so BitLocker on Docker root dir
                # SECRET : DECLARATIVELY @ YAML (v3.1+)  
                    version: "3.7"
                    # Defined per:
                    secrets:
                        # FILE SOURCE (file: ) may be LOCAL even if service node is remote.
                        postgres_user:
                            file: ./psql_user.txt  # @ EXISTING FILE (create secret therefrom)
                        postgres_password:
                            external: true         # @ EXISTING OBJECT (KEY=VAL secret exists) 
                        foo_v1:
                            external: true
                    services:
                        # Assigned per SERVICE …
                        dbp:
                            secrets:        # https://docs.docker.com/compose/compose-file/#secrets  
                                - postgres_user 
                                - postgres_password
                                - foo_v1
                                #… Each @ Docker's default mnt pt for secrets : /run/secrets/*
                        foo:
                            secrets: # LONG syntax (Note queer indentation)
                                - source: test_secrets
                                  target: /etc/hide/test_secrets # Non-default path okay
                                  uid: "$CTNR_USER"
                                  gid: "$CTNR_USER"
                                  mode: 0440
                                  #… if mismatch of UID:GID with such of user, then make WORLD READABLE (mode 0444)

                            environment:    # https://docs.docker.com/compose/compose-file/#environment  
                                POSTGRES_USER_FILE: /run/secrets/postgres_user
                                POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
                                FOO_V1: /run/secrets/foo_v1
                                # … pseudo-path(s) @ container; an encrypted in-memory FS 
                                # HOWEVER, recipient (app) must treat as a file, NOT a string.

                # SECRET : IMPERATIVELY @ `docker service update` 
                    # https://docs.docker.com/engine/reference/commandline/secret_create/
                    # ***************************************************************************
                    # ROTATE SECRET(s) without taking down a service, yet KEEP the same TARGET KEY:
                        echo newsecret | docker create secret KEY_v2 - #… Create new version (source) 
                        docker service update \
                            --secret-rm KEY \
                            --secret-add source=KEY_v2,target=KEY \
                            $_SVC
                    # ***************************************************************************
                    # CREATE per STRING or FILE  
                        docker secret create [OPTIONS] KEY [FILE|-]
                        # creates a `KEY:VAL` pair (Object @ Docker engine) per string or file. 
                            printf 'VAL' | docker secret create 'KEY' -  # Vulnerability: VAL @ bash history 
                            # OR
                            docker secret create 'KEY' 'FILE'            # Vulnerability: FILE @ host drive  
                        # E.g., (Best practice is to VERSION it.) 
                        docker secret create 'app-sec-v1.0.1' ./foo/bar \
                            --label env='dev' --label ver='1.0.1'
                    # per SERVICE UPDATE : add/delete
                        docker service update … --secret-rm KEY
                          --secret-add source=KEY,target=KEY # Add/update a secret on a service
                          --secret-rm LIST_OF_KEYs               # Remove (delete) secret(s)
                    # per SERVICE CREATE 
                        docker service create … --secret source=KEY,target=KEY …
                        docker service create … --secret KEY -e VAL_FILE=PATH …  
                            # Note "`*_FILE`" is keyword; triggers file-method (vs string method)
                                target=$(cat /foo/bar)  # String method
                                VAL_FILE=/foo/bar       # File method
                        # E.g., 
                        docker service create … --secret 'app-sec-v1' \
                            -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/app-sec-v1
                    # @ SERVICE UPDATE (-add/-rm; change) : EXISTING (old, new) secrets (keys)
                        # CANNOT change secret even if removed in this manner LEST SERVICE IS TAKEN DOWN.
                        docker service update … --secret-rm oldKEY
                        # The following DOES NOT rotate any existing secret: 
                        # The app too must be update (out-of-band) with new secret name.
                        newSECRET="source=KEYnew,target=KEY"
                        docker service update … --secret-rm oldKEY  --secret-add $newSECRET
                    # LIST 
                        docker secret ls
                    # INSPECT (meta)
                        docker secret inspect KEY  
                    # DELETE
                        docker secret rm KEY  # per NAME|HASH  
                    # COMMIT SECUREly to IMAGE
                            docker commit $(docker ps --filter name=redis -q) 'committed_redis'
                            # VALIDATE SECURE : CANNOT read 
                            docker run --rm -it 'committed_redis' cat /run/secrets/my_secret_data
            # HEALTHCHECKs on CONTAINERs, per APP; (Docker v1.12)  https://docs.docker.com/engine/reference/builder/#healthcheck  
            # 3 STATEs : "starting"|"healthy"|"unhealthy" (test per interval param)  
            # Supported @ Dockerfile & Compose (YAML), docker run and Swarm services  
                docker container ls         # shows last healthcheck
                docker inspect $_CTNR       # shows LAST 5 HEALTHCHECKs, "Failstreak", …
                docker run …               # takes no action on an unhealthy container
                docker service …           # waits for healthcheck pass
                curl -f $_AppURL || exit 1  # curl is silent on fail; 
                # … Docker healthcheck scheme expects exit code 1 on fail, but curl exit codes vary.  
            # @ Dockerfile  ( exit 1 === false ; EITHER OKAY)
                ARG API_HOST 
                ARG API_PORT
                # defaults: 30s/30s/0s/3
                HEALTHCHECK \
                    --interval=5s \
                    --timeout=3s \
                    --start-period=0s \
                    --retries=3 \
                    CMD curl -Ifs http://${API_HOST:-localhost}:${API_PORT:-5555}/health || exit 1
                    # CMD for healthcheck VARIES PER APPLICATION, e.g., @ PostgreSQL, …  
                        CMD pg_isready -U postgres || exit 1 
            # @ docker run 
                docker run -d --name db \
                    --health-cmd "curl --fail http://localhost:9200/_cluster/health || false" \
                    --health-interval=5s \
                    --timeout=3s 
            # @ docker service … the following example waits the default 30s for healthcheck …
                docker service create --health-cmd "pg_isready -U postgres || exit 1" dbp 
                docker service update --health-cmd "curl -I -f -s --connect-timeout 2 localhost:5555 || exit 1" api
docker-machine  # VMs for Multi-node SWARM; See "REF.Docker.Get-Started{.md|.html}" 
    # VIRTUAL MACHINEs (VM) tool for DEV/TEST Environment; manage the hosts (VMs)
    # VM CONFIGs @ USERPROFILE\.docker\machine\machines\VMname\config.json
    # … for Linux|WSL, convert paths to POSIX, @ each config.json, and symlink to ~/.docker/…
    # Docker Machine CLI tool; installs Docker Engine on VMs (virtual hosts); 
    # manages the hosts; to create Docker hosts ANYWHERE; 
    # Local (Mac or Windows box), corp network, data center, cloud providers (Azure, AWS, DO).
    # Overview       https://docs.docker.com/machine/overview/
    # Refence        https://docs.docker.com/machine/reference
    #                http://docs.docker.oeynet.com/machine/reference/  (China)
    # Drivers        https://docs.docker.com/machine/drivers/ 
    # @ AWS          http://docs.docker.oeynet.com/machine/examples/aws/ 
    # @ DigitalOcean http://docs.docker.oeynet.com/machine/examples/ocean/ 
    # boot2docker    https://github.com/boot2docker/boot2docker/releases
    # Alt @          http://play-with-docker.com 
    # CREATE VM 
        # ISSUE: boot2docker.iso v18.09 BREAKS ingress/overlay network)
        # https://github.com/docker/machine/issues/4608  
        # FIXED: 2020-10-07 
        # @ Hyper-V VM
        docker-machine create -d hyperv \
            --hyperv-virtual-switch "External-GbE" \
            #--hyperv-boot2docker-url "https://github.com/boot2docker/boot2docker/releases/download/v18.06.1-ce/boot2docker.iso" \
            --hyperv-memory 1024 \
            --hyperv-disk-size 10000 \
            $_VM  
        # @ AWS EC2 
        docker-machine create \
            --driver 'amazonec2' \
            --amazonec2-ami 'ami-007a607c4abd192db' \
            --amazonec2-instance-type 't4g.nano' \
            --amazonec2-security-group 'docker-machine' \
            --amazonec2-region 'us-east-1' \
            --amazonec2-zone 'd' \
            $_VM  
        # @ Generic : Add an existing AWS EC2
        docker-machine create \
            --driver 'generic' \
            --generic-ip-address=$ip \
            --generic-ssh-user=$ssh_user \
            --generic-ssh-key=$ssh_private_key \
            $_VM
        # @ Exoscale (untested) 
        # https://www.exoscale.com/syslog/private-networking-with-docker/
        docker-machine create \
            --driver 'exoscale' \
            --swarm --swarm-master \
            --swarm-discovery="consul://$(docker-machine ip $mgr_vm):8500" \
            --engine-opt="cluster-store=consul://$(docker-machine ip $mgr_vm):8500" \
            --engine-opt="cluster-advertise=eth0:2376" \
            $_VM
        # VM CONFIG (JSON) …
        cat "~/.docker/machine/machines/$_VM/config.json"
            # PATHING @ WSL; whereof paths are, e.g., "C:\\foo\\bar"
                # So, to use docker-machine on such a VM @ WSL, convert paths to POSIX …
                cat 'config.json' | sed 's#\\\\#/#g' | sed 's#C:#/c#g' > 'config.WSL.json' # then rename file
    # LIST VMs : NAME, DRIVER, STATE, URL (PROTO:IP:PORT) 
        docker-machine ls  # Asterisk (*) @ VM of Swarm LEADER.
        #… that node's Docker Engine (daemon) CONTROLS ALL OTHERS of the Swarm cluster.
    # START|STOP|RESTART|KILL commands 
        docker-machine start|stop|restart|kill VM1 [VM2 …]
        # KILL (hard stop) ALL
        docker-machine kill $(docker-machine ls -q)
        # … per PS for-loop (if named: vm1, vm2, … vmN)
        PS> for($i=1; $i -le 3; $i++){docker-machine kill "vm$i"}
    # REMOVE (DELETE) VM(s)   
        docker-machine rm VM1 [VM2 …]
    # REMOVE (DELETE) ALL VMs  
        docker-machine rm $(docker-machine ls -q) 
    # URL (PROTO:IP:PORT) of "host" (A swarm VM with its own Docker Engine)  
        docker-machine url $_VM  # tcp://3.236.129.99:2376
    # IP (Public IPv4 Address) of "host" (A swarm VM with its own Docker Engine)
        docker-machine ip  $_VM  # 3.236.129.99 
    # CONFIG : Show TLS info; {ca,cert,key}.pem
        docker-machine config $_VM 
    # INSPECT (Print 'config.json' @ ~/.docker/machine/machines/<VM_NAME>/)
        docker-machine inspect $_VM
    # PROVISION (recover from fail @ prior provisioning)
        docker-machine provision $_VM 
    # REGENERATE CERTs (TLS; {ca,cert,key}.pem)
        rm ~/.docker/machine/machines/$_VM/{ca,cert,key,server,server-key}.pem -f
        docker-machine regenerate-certs $_VM --force
        #… easier to remove machine (rm) and then add it (create) back again, depending on the driver.
    # ROTATE CERTS
        docker swarm ca --rotate
    # CERTS location : COMMON (from which per-machine certs and such are generated):
        ls ~/.docker/machine/certs 
    # CERTs location : PER MACHINE (Certs + SSH keys + config.json + …):
        ls ~/.docker/machine/machines/${_VM}
    # SSH access into VM   
        docker-machine ssh $_VM COMMAND  # Run shell COMMAND, then exit.
        docker-machine ssh $_VM          # Interactive shell (session).
        # Docker-native SSH tool  https://docs.docker.com/machine/reference/ssh/#different-types-of-ssh
        docker-machine --native-ssh ssh $_VM  #… some behavior differs from that of OpenSSH. 
        #… defaults to this if an existing ssh tool is not found.
        #… sans docker-machine …
        ssh -i ${_PRIVATE_KEY} ${user}@${host_name_OR_public_ip} #… e.g., …
        ssh -i ~/.docker/machine/machines/${_VM}/id_rsa ${user}@${host_name_OR_public_ip}
        # SSH KEYs … where/what/validate …
        # @ VM (IPv4 Addr: 172.31.4.5 is ??? local; behind-NAT ???) 
            [ec2-user@ip-172-31-4-5 ~] 
            $ ssh-keygen -lf .ssh/authorized_keys
            2048 SHA256:XwZbFaWZeXwwbP7lDxvuQ9IsU6jqYNsj81R8Uha4/pM a1 (RSA) 
        # @ Host (local machine running the docker-machine tool)
            $ ssh-keygen -lf ~/.docker/machine/machines/${_VM}/id_rsa.pub  
            2048 SHA256:XwZbFaWZeXwwbP7lDxvuQ9IsU6jqYNsj81R8Uha4/pM no comment (RSA)
            # NOTE equivalents: $HOME, "~"; "/c/Users/$USER" @ MINGW64; "/c/HOME" @ WSL
    # SCP
        # Copy a file 
        docker-machine scp $_FILE $_VM:~            # local $_FILE to Home dir @ $_VM
        # Copy an entire dir (recurse)
        docker-machine scp -r $(pwd) $_VM:~         # local PWD to home dir @ $_VM (typically `/home/ec2-user`)
        docker-machine scp -r $(pwd) $_VM:~/app/    # local PWD to ~/app @ $_VM
        docker-machine scp -r $(pwd) $_VM:~/app     # local PWD to ~/app/(last-child-folder @ local PWD) @ $_VM
    # Rsync : PUSH to AWS VM : from local $PWD to remote $HOME/assets/ 
        rsync -atuze "ssh -i $_PRIVATE_KEY" $(pwd)/assets/ ${_USER}@${_HOST}:~/assets/
            # - @ CYGWIN or WSL; FAILs @ MINGW64
            # - Creates destination dir, `~/assets`, if not exist.
                # The default $HOME dir (~) DIFFERs per VM driver/OS, e.g., EXPANDS TO …
                    # /home/docker  @ Hyper-v
                    # /home/ubuntu  @ AWS 
    # CONFIGURE environment of Docker CLI tool (`docker …`) to a NODE (VM); @ CURRRENT SHELL only
        docker-machine env $_VM  
            --swarm     # Display the Swarm config instead of the Docker daemon
            --shell     # config env for specified shell: [fish, cmd, powershell, tcsh], default is sh/bash
            --unset, -u # Unset variables instead of setting them
            --no-proxy  # Add machine IP to NO_PROXY environment variable
        # … returns INSTRUCTION on HOW TO CONFIGURE Docker CLI tool to that VM …
        # SET 
            eval "$(docker-machine env $_VM)"                # Linux
            docker-machine.exe env $_VM | Invoke-Expression  # PowerShell 
            env | grep DOCKER
                # DOCKER_MACHINE_NAME=h1
                # DOCKER_CERT_PATH=C:\Users\X1\.docker\machine\machines\h1
                # DOCKER_TLS_VERIFY=1
                # DOCKER_HOST=tcp://192.168.1.26:2376  #… that of VM to which we are configured.
            #… Docker commmands then run against that host; '*' (Docker server/daemon thereof)
            docker-machine ls  # List machines configured for the CLI … 
            ~/.docker/machine/machines/$vm/  # Configuration(s) per machine, per VM name
        # SHOW 
            docker-machine config $_VM  #=>
                # --tlsverify
                # --tlscacert="C:\\Users\\X1\\.docker\\machine\\machines\\h1\\ca.pem"
                # --tlscert="C:\\Users\\X1\\.docker\\machine\\machines\\h1\\cert.pem"
                # --tlskey="C:\\Users\\X1\\.docker\\machine\\machines\\h1\\key.pem"
                # -H=tcp://192.168.1.26:2376
            docker-machine active 
                h1  # VM (DOCKER_HOST) name to which the docker CLI is configured.
            docker-machine url 
                tcp://192.168.1.26:2376
        # UNSET 
            eval "$(docker-machine env -u)"
            env | grep DOCKER  #=>
                # DOCKER_MACHINE_NAME=h1
                # DOCKER_CERT_PATH=C:\Users\X1\.docker\machine\machines\h1
                # DOCKER_TLS_VERIFY=1
                # DOCKER_HOST=tcp://192.168.1.26:2376
    # MOUNT : mounts host dir @ VM dir
        # REQUIREs sshfs & fuse @ host; fails @ WSL (@ fuse); purportedly works @ WSL2.
        docker-machine ssh $_VM mkdir /home/x1           # create VM path if not exist
        docker-machine mount $_VM:/home/x1 /c/TEMP/$_VM  # c/TEMP/$_VM exists (@ host) and is empty. 
        # FS Owner/Perms of bind mount set per host or …
        --user $uid:$gid 
        # E.g., 
            _VM='h1'
            mkdir foo
            docker-machine ssh $_VM mkdir foo
            docker-machine mount $_VM:/home/docker/foo foo  # FAILs @ WSL
            touch foo/bar
            docker-machine ssh $_VM ls foo
    # SWARM INIT/JOIN/LEAVE, per VM (NODE) 
        docker-machine ls  #… to GET $_SWARM_MGR_IP
        # INIT (returns token); this VM is made Swarm Manager
            # http://docs.docker.oeynet.com/engine/reference/commandline/swarm_init/#description
            export LEADER_IP=$(docker-machine ip $_VM) #… Public or Private IPv4 Address 
            #… must be public if cross vendor?
            docker-machine ssh $master "docker swarm init --advertise-addr eth0:2377"
                --advertise-addr IP|INTERFACE[:PORT]
                # … specifies address advertised to other swarm members for API access. 
                # Additional option …
                --listen-addr    IP|INTERFACE[:PORT]  # DEFAULT is 0.0.0.0:2377
        # JOIN (add node); this VM is Worker node  
            #  *************************************************************
            #   NO. Rather, configure terminal, and use Docker CLI directly 
                docker swarm init …
            #  *************************************************************
            export masterTkn=$(docker-machine ssh $_LeaderVM "docker swarm join-token worker -q")
            echo $masterTkn  # SWMTKN-1-<PER.SWARM.MGR>-<AS.MGR|AS.WKR>
            docker-machine ssh $worker1 "docker swarm join --token $masterTkn $masterIP"
            docker-machine ssh $worker2 "docker swarm join --token $masterTkn $masterIP"
            # PORT 2377 is that of the Control Plane; may omit, but use ALWAYS/ONLY for JOIN; NEVER for commands or data.
        # LEAVE SWARM command (first @ each worker, then @ master(s); `--force` required only @ last master.)
            docker-machine ssh $_VM "docker leave --force" # do for each node (VM)
            #… DO only AFTER TEARDOWN of DEPLOYment: `docker swarm rm $SWM_NAME` 
        # INFO : IP/CONFIG
            docker-machine ip|config $_VM # Connection info; Cert paths & PROTO//:IP:PORT
# PRJ : Swarm Cluster @ Docker (@DfW) 
    # (See: "Getting Started Pt. 4" and "Docker-Mastery [2018] [Udemy]"/08.)
    # Create 2 or 3 nodes (VMs)
    docker-machine create -d hyperv --hyperv-virtual-switch "External-GbE" "vm1"
    docker-machine create -d hyperv --hyperv-virtual-switch "External-GbE" "vm2"

    # View nodes 
    docker-machine ls
    NAME   ACTIVE   DRIVER   STATE     URL                       SWARM  …
    vm1    -        hyperv   Running   tcp://192.168.1.37:2376  
    vm2    -        hyperv   Running   tcp://192.168.1.38:2376  
    # Set vm1 as Swarm Mgr
    _SWARM_MGR = "vm1"
    _SWRM_MGR_IP = "192.168.1.37"
    docker-machine ssh $_SWARM_MGR "docker swarm init --advertise-addr $_SWRM_MGR_IP"
    # Add vm2 to Swarm as Worker
    docker-machine ssh "vm2" "docker swarm join --token SWMTKN-1-4rt8ybrzm3wzvax543es3psxsqaspllfowhc4pr2ks1gua6vcp-d2prqzvgyo18396rzs70lyzmg 192.168.1.37:2377"

    # View Swarm nodes
    docker-machine ssh $_SWARM_MGR "docker node ls"

    # Docker Network @ Host
    docker network ls

    # Docker Network @ VM 
    docker-machine ssh $_SWARM_MGR "docker network ls"

    # Configure shell to SWARM_MGR (VM) server
    & docker-machine.exe env $_SWARM_MGR | Invoke-Expression

    # Deploy stack
    docker stack deploy -c 'example-voting-app-stack.yml'
    # View
    docker stack ls
    docker stack ps app1
    docker stack services app1

    # Test
    $ curl -I 192.168.1.37:4000

# PRJ : aws-cli @ docker container
    apk -v --update add \
        python py-pip \
        && pip install --upgrade awscli python-magic \
        && rm /var/cache/apk/*

    # per Dockerfile  https://github.com/mesosphere/aws-cli/blob/master/Dockerfile
        FROM alpine:3.6
        RUN apk -v --update add python py-pip \
            && pip install --upgrade awscli python-magic \
            && rm /var/cache/apk/*
        ENV AWS_PROFILE='ops-admin'
        #VOLUME /project
        WORKDIR /root
        ENTRYPOINT ["sh"]
    
    # build/run : bind-mount $HOME
        docker build -t aws:latest .  # 108MB
        docker run --rm -it -v ~:/root 'aws' 

