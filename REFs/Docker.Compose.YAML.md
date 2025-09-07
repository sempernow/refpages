# [Docker Compose File `v3.8`](https://docs.docker.com/compose/compose-file "docs.docker.com")

## [Networks](https://docs.docker.com/compose/compose-file/#networks) 

## Volumes @ `docker stack deploy` ( `docker-stack.yml`)

>Tasks (containers) backing a service can be deployed on any node in a swarm; may be different node each time service is updated.

So ___no named volumes___. Instead uses ___anonymous volume__ per task. These ___do not persist___; are as ephemeral as container.

To persist, use a named volume and a volume driver that is multi-host aware, so that the data is accessible from any node. Or, set constraints on the service so that its tasks are deployed on a node that has the volume present.

[`example-voting-app`](https://github.com/docker/labs/blob/master/beginner/chapters/votingapp.md) 

```yaml 
version: "3.8"
services:
    db:
    image: postgres:9.4
    volumes:
        - db-data:/var/lib/postgresql/data
    networks:
        - backend
    deploy:
        placement:
            constraints: [node.role == manager]
```

[`healthccheck`](https://docs.docker.com/compose/compose-file/#healthcheck)

```yaml
healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost"]
    interval: 1m30s
    timeout: 10s
    retries: 3
    start_period: 40s
```

[`ports`](https://docs.docker.com/compose/compose-file/#ports)

```yaml
# SHORT syntax is HOST:CTNR (USE STRINGs)
ports:
    - "3000"
    - "3000-3005"
    - "8000:8000"
    - "9090-9091:8080-8081"
    - "49100:22"
    - "127.0.0.1:8001:8001"
    - "127.0.0.1:5000-5010:5000-5010"
    - "6060:6060/udp"
    - "12400-12500:1240"

# LONG syntax (equiv to "8080:80/tcp")
ports:
    - target: 80       # @ CTNR
      published: 8080  # @ HOST
      protocol: tcp  
      mode: host 
      #... ingress @ swarm mode; to be load balanced.
```

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

