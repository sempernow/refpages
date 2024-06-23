# [CNCF Distribution Registry](https://distribution.github.io/distribution/) 

>The Registry is a stateless, highly scalable server-side application that stores and lets you distribute container images and other content. The Registry is open-source, under the permissive Apache license.

## [Deploy a local Docker Registry](https://distribution.github.io/distribution/about/deploying/)

### TL;DR

```bash
# Deploy a CNCF Distribution registry
img='registry:2.8.3'
vi config.yml # Custom config (bind mount or config map)

docker run --rm -d --name registry \
    -p 5000:5000 \
    -v /tmp/local_registry:/var/lib/registry \
    -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
    $img 
    #... flag: --restart=always is not reliable.
    
    # If want local DNS resolution of registry.local:5000
    export reg='registry.local'
    echo "127.0.0.1 $reg" |sudo tee /etc/hosts

```

### [`config.yml`](config.yml) | [List of Configuration Options](https://distribution.github.io/distribution/#list-of-configuration-options "distribution.github.io")

Commandline override pattern:

- "`http.tls.certificate: VAL`" maps to "`-e REGISTRY_HTTP_TLS_CERTIFICATE=VAL`"

### Advanced deployments

```bash
# +TLS 
docker run --rm -d -p 5000:5000 --name registry \
    -v $host_path_to_images:/var/lib/registry \
    -v $host_path_to_certs:/certs \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -p 443:443 \
    $img

# +HTTP Basic Auth via Apache server (httpd)
docker run --entrypoint htpasswd httpd:2 -Bbn $user $pw > $host_path_to_auth/htpasswd
docker run --rm -d -p 5000:5000 --name registry \
    -v $host_path_to_auth:/auth \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    -v $host_path_to_certs:/certs \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    $img

# Enables login ...
docker login $registry_domain:5000

# Run as a Service
docker secret create domain.crt $host_path_to_certs/domain.crt
docker secret create domain.key $host_path_to_certs/domain.key
docker service create \
    --name registry \
    --secret domain.crt \
    --secret domain.key \
    --constraint 'node.labels.registry==true' \
    #--mount type=bind,src=$host_path_to_images,dst=/var/lib/registry \
    -v $host_path_to_images:/var/lib/registry \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/run/secrets/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/run/secrets/domain.key \
    -p 443:443 \
    --replicas 1 \
    $img
```
- Registry endpoint: `http://localhost:5000`
- [`/etc/docker/daemon.json](https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file)
    ```json
    {
        "insecure-registries": [
            "localhost:5000", 
            "registry.local:5000", 
            "172.27.240.169:5000"
        ]
    }
    ```
- Host paths (`$host_path*`) are to be created; exist only for their purpose here.
- LB/Reverse-proxy considerations 
  ([NGINX example](https://distribution.github.io/distribution/recipes/nginx/)):   
    - For all responses to any request under the “`/v2/`” url space, the `Docker-Distribution-API-Version` header should be set to the value “`registry/2.0`”, even for a `4xx` response. This header allows the docker engine to quickly resolve authentication realms and fallback to version 1 registries, if necessary. Confirming this is setup correctly can help avoid problems with fallback.  
    - In the same train of thought, you must make sure you are properly sending the `X-Forwarded-Proto`, `X-Forwarded-For`, and Host headers to their “`client-side`” values. Failure to do so usually makes the registry issue redirects to internal hostnames or downgrading from https to http.

## Client Requests to API

```bash

# Docker Registry v2 API 
# https://distribution.github.io/distribution/spec/api/
# Validate the registry abides /v2/
registry=registry.local:5000

curl -I https://$registry/v2/
    # HTTP/1.1 401 Unauthorized                       <<< REQUIRED of v2
    # content-type: application/json
    # docker-distribution-api-version: registry/2.0   <<< REQUIRED of v2
    # www-authenticate: Bearer realm="https://auth.docker.io/token",service="registry.docker.io"
    # ... The WWW-Authenticate header value provides token-request params, so ...

# GET token : scoped to target image (library/busybox)
    # See WWW-Authenticate header for the actual auth endpoint, which may be other than "/v2/"
    curl "https://$registry/token?service=registry.docker.io&scope=repository:$app:pull"
        # {"token":"...","access_token": "...", ...}

# GET manifest : The DIGEST is NOT in the JSON, but in the HEADER
    ## @ v2.3+, with GET or HEAD request MUST include else bogus reponse:
    auth="Authorization: Bearer $token"
    accept='Accept: application/vnd.docker.distribution.manifest.v2+json'
    repo=''
    app='busybox'
    name="$repo/$app"
    tag='latest'
    curl -H "$auth" -H "$accept" -isS https://$registry/v2/$name/manifests/$tag 

# GET catalog of its image repos : JSON response body
    curl -s http://$registry/v2/_catalog  # {"repositories: ["repo/app:tag",...]"}

# GET tags/list : all tags of an image APP : JSON response body
    curl -s https://$registry/v2/$name/tags/list \
        |tee list.$app.tags.json # {"name":"repo/app","tags":["a","b",...]}

# GET flat list of ALL IMAGES of a Distribution Registry v2 
    # in a single pipeline of two GET requests using jq to flatten 
    # JSON responses to resulting format ([REPO/]APP:TAG).
    curl -s http://$registry/v2/_catalog \
        |jq -Mr .[][] \
        |xargs -I{} curl -s http://$registry/v2/{}/tags/list \
        |jq -Mr '.tags[] as $tag | "\(.name):\($tag)"'
            # busybox:1.31.1-musl
            # nginx:1.25-alpine3.18
            # nginx:1.25.4-alpine-otel
            # redhat/ubi8:8.7
            
# GET all content of registry, both repos and images lists, 
# in both JSON and flat-list formats.
    curl -s http://$registry/v2/_catalog \
        |tee catalog.json \
        |jq -Mr .[][] \
        |tee catalog.repositories.log \
        |xargs -I{} curl -s http://$registry/v2/{}/tags/list \
        |jq -Mr . --slurp \
        |tee all.tags.list.json \
        |jq -Mr '.[] | .tags[] as $tag | "\(.name):\($tag)"' \
        |tee all.images.log

```
```bash
# PUSH : Use docker (client)
    docker tag $app:$tag $registry/$app:tag
    docker push $registry/$app:tag

    # PUSH all in local docker cache to registry
    dit ()
    {
        function d ()
        {
            docker image ls --format "table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}" $@
        }
        h="$( d |head -n1)"
        echo "$h"
        d "$@" |grep -v REPOSITORY |sort -t' ' -k2
    }
    export -f dit
    dit |grep -v $registry |grep -v IMAGE |awk '{print $2}' \
    |xargs -I{} /bin/bash -c '
        docker tag $1 $0/$1
        docker push $0/$1
    ' $registry  {}

```
```bash
# DELETE an image from Registry v2 
    # 1. HEAD : returns the digest required of any subsequent DELETE request.
    # Digest is returned in HTTP response header: "Docker-Content-Digest: sha256:abc...123"
        digest="$(
            curl -H "$accept" -H "$auth" -siSX HEAD \
                https://$registry/v2/$name/manifests/$tag \
                |grep -i docker-content-digest \
                |awk '{printf "%s\n",$2}' \
                |sed 's/\W//g' \
                |sed 's/sha256/sha256:/' \
        )"  
            # HTTP/1.1 200 OK
            # ...
            # docker-content-digest: sha256:521...945
            # ...
                # Note the /v2 API will FAIL SILENTLY, REGARDLESS of reason 
                # (auth fail, no Accept header, ...). 
                # Yet its HEAD response ALWAYS INCLUDES a digest. 
                # The sole distinction between success and failure 
                # is that the digest is real on success and bogus on failure.
                # Attempting step 2 or other /manifest/ request with bogus digest will fail (HTTP 4xx or 5xx)

    # 2. DELETE : /v2/<app>/manifests/<reference>
    # HTTP 202 response on success
        curl -H "$auth" -H "$accept" -sSX DELETE \
            https://$registry/v2/$name/manifests/$digest 

```

## `docker` : Load/Push/Pull/Save

```bash
registry='registry.local:5000'

# Load all saved images (*.tar) into Docker cache
find . -type f -exec docker load -i {} \;


# Tag/Push to local registry

## Define helper function to list only REPO:TAG of all cached images
list(){ docker image ls --format "table {{.Repository}}:{{.Tag}}"; }
export -f list

## (Re)Tag cached images (once), 
## replacing registry (if in name) with $registry, else prepending $registry/
list |grep -v TAG |grep -v $registry |xargs -IX /bin/bash -c '
    docker tag $1 $0/${1#*/}
' $registry X

## Push images (to $registry) 
list |grep $registry |xargs -IX /bin/bash -c '
    docker push $1
' _ X


# Get catalog of registry images
curl -s http://$registry/v2/_catalog |jq .
#> {"repositories": ["abox",...,"kube-apiserver","kube-controller-manager",...]}

# IF server and client are behind same proxy server
curl -s --noproxy '*' http://$registry/v2/_catalog |jq .


# Get all images (tags) of a name ([REPO/]APP)
name='bitnami/postgresql'
curl -s http://$registry/v2/$name/tags/list

# Save (archive) the container image
fname="${name//\//.}"
tag='12.19.0'
docker save $registry/${name}:$tag |gzip -c > ${fname//:/_}.tar.gz

```

### Login to remote registry

```bash
registry='ghcr.io'

docker login $registry -u $username -p $accesstoken
```

