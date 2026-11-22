# [Docker](https://www.docker.com "docker.com") | [Docs](https://docs.docker.com/reference/ "docs.docker.com/reference") | [Hub](https://hub.docker.com/explore/ "hub.docker.com") | [Wikipedia](https://en.wikipedia.org/wiki/Docker_(software) "en.wikipedia.org") 

Docker (Linux)  
Docker for Windows (DFW)  
Docker for Mac (DFM)

- Runs as __Server__ (daemon) and __Client__ (`docker` CLI and others) ...  
- Docker Client (Docker Engine) talks to the server   
- Docker Server (Docker Daemon) talks to Image Cache (local) then Docker Hub (Image Store)   

## Install ([MD](Docker.Install.html "@ browser"))

## `PRJ.Docker.Get-Started` ([MD](PRJ.Docker.Get-Started.html "@ browser")) 

## [`Docker.sh`](Docker.sh)

## Background  
Docker predecessor was [dotCloud](https://www.crunchbase.com/organization/dotcloud "CrunchBase.com"), a Linux container technology startup.  

Docker accesses the Linux kernel's virtualization features, either directly using the `runC`/`libcontainer` library, or indirectly using `libvirt`, [LXC](https://en.wikipedia.org/wiki/LXC "Wikipedia :: Linux Containers") or `systemd-nspawn`.

- [`containerd` (GitHub)](https://github.com/containerd/containerd "GitHub/containerd")   
An open-source [industry-standard container runtime](https://containerd.io/ "containerd.io"). __The core container runtime__ of the Docker Engine daemon (`dockerd`). Uses `runC` (and [`grpc` for comms](https://grpc.io/ "grpc.io")) [for spawning and running containers](https://stackoverflow.com/questions/41645665/how-containerd-compares-to-runc "StackOverflow 2017") per OCI spec. 
    - [`runC`/`libcontainer` (GitHub)](https://github.com/opencontainers/runc "GitHub/OCI/runC")  
    A specification and runtime code; begot [Open Container Initiative](https://github.com/opencontainers "GitHub/opencontainers") (OCI). A CLI tool for spawning and running containers per OCI specifications. 
        - `libcontainer`  
        The original virtualization spec/runtime; _merged_ with `runC`. In effect, this is Docker's fork of LXC.

## Architecture 

- __Container__  
Virtualized OS; an isolated area of an operating system (OS) with resource limitations applied. Leverages __Linux kernel primitives__ (__Namespaces__ &amp; __Control Groups__);  [Namespaces](https://en.wikipedia.org/wiki/Linux_namespaces "Wikipedia :: Linux Namespaces") for isolation; Control Groups ([Cgroups](https://en.wikipedia.org/wiki/Cgroups "Wikipedia")) for resource limits. The Docker Engine ("The Daemon") handles those low-level primitives.  

<a name="unionfs"></a>

- [__Union__ FS/Mount](https://en.wikipedia.org/wiki/Union_mount "Wikipedia")   
Combines multiple directories into one that appears to contain their combined contents; allows immutable image layers to form a useful, mutable container during both build and operational runs. Though images (and each comprising layer thereof) are immutable, containers are modifiable by the __Copy-on-Write__ ([CoW](https://en.wikipedia.org/wiki/Copy-on-write "Wikipedia")) mechanism. The __container stores changes on a R/W layer__ on top of the underlying (RO) image layers. Docker currently implements Union FS/Mount [using various storage drivers](https://docs.docker.com/v17.12/storage/storagedriver/select-storage-driver/) (e.g., `overlay2`), supporting `xfs`, the underlying filesystem.

- [__Namespaces__](https://en.wikipedia.org/wiki/Linux_namespaces "Wikipedia :: Linux Namespaces")   
Carves up the OS into multiple _virtual_ OS (on which the desired app runs). Unlike VMs, all Virtual OS (containers of a node) share the same, single host (node) OS. __Linux Namespaces__ (per container):  
    - Process IS (`pid`)
    - Network (`net`)
    - Filesystem/mount (`mnt`); root FS
    - Inter-proc comms (`ipc`); shared memory 
    - UTS (`uts`); hostname
    - User (`user`); new; map host:container users 

- __Docker Engine__   
Was a monolith; refactored per OCI standards/specs for both Image &amp; Runtime. Is now entirely separate; modular design; can upgrade Engine while its containers are running.

## Software 
- __Server__ [(`dockerd`)](https://docs.docker.com/engine/reference/commandline/dockerd/ "@ docs.Docker.com")  a.k.a. __Docker Engine__ a.k.a. The __Daemon__.  The persistent __host__ process (daemon) that manages  containers and handles container objects; listens for requests sent via the __Docker Engine API__. Interaces with Linux kernel. "_A self-sefficient runtime for containers._"  

- __Client__ [(`docker`)](https://docs.docker.com/engine/reference/commandline/docker/ "@ docs.Docker.com") a.k.a. __Docker Engine (CLI/Tool)__. The main CLI for Docker Engine; allows users to interact with Docker daemons.

## Editions 
- __Docker CE__  
Docker Engine (CE)  
    - Community Edition (Free)  
- __Docker EE__   
    - Enterprise Edition (Pay)  
    RBAC, scanning, Image promos, ...
    - Docker Engine (EE)  
        - Docker Certified Infra
    - Ops UI (Web GUI)  
        - "Universal Control Plane" (UCP)  
    It's a Docker app (Swarm Cluster)
    - Secure Registry  
        - Docker Trusted Registry (DTR)  
        An on-prem registry.

## Objects 
- __Image__  
An image is a combination of a JSON [Image Manifest](https://docs.docker.com/registry/spec/manifest-v2-2/) file and individual layer files. A layer is a [__tarball__ of files](https://cameronlonsdale.com/2018/11/26/whats-in-a-docker-image/ "'What's in a Docker image?' - Nov 2018 @ CamperonLonsdale.com") __built__ from (`rootfs`) __filesystem views__; loosely coupled layers; includes the app, its dependencies, and a JSON manifest, all for the Docker runtime. A stack of [Union fs](#unionfs) layers, unified by a storage driver, per manifest instructions. `Storage Driver: Overlay2`  (@ `docker system info`)
    - __Stateless__ and __immutable__; A read-only template. "`IMAGE ID`" references the [`SHA256` hash of the image](https://docs.docker.com/engine/reference/commandline/images/#list-image-digests "@ docs.Docker.com") the globally unique __content-addressable identifier__. This ID is [an attack vector necessitating countermeasures](https://docs.docker.com/engine/security/trust/content_trust/ "'Docker Content Trust' @ docs.Docker.com").  
    - The container host provides the (Linux) kernel, so the image (tarball) ___can be a single file___ (binary), such as [a carefully compiled Golang app](https://www.admintome.com/blog/deploying-go-applications-using-docker-containers/ "'Deploying Go applications using Docker containers' - Nov 2018 @ AdminToMe.com"); megabytes. At the other extreme, it can be a fully loaded Ubuntu distro, including an assortment of packages installed therein; gigabytes.  

- __Container__  
A runtime instance of a Docker image; a process of the Docker runtime (daemon: `dockerd`); __created__ of the image, its execution environment, and a standardized set of instructions. A [writable layer](https://docs.docker.com/storage/storagedriver/#images-and-layers) on top of the image. 
    - Designed to isolate and run a single userland process in a virutalized OS.  
    - The Docker runtime (daemon) handles the container's system calls to the host kernel.
    
- [__Swarm__](https://docs.docker.com/engine/swarm/ "docs.docker.com/engine/swarm")  
A cluster of one or more Docker Engines (nodes) running in swarm mode. A set of cooperating Docker Engine daemons that communicate through their API. A service allowing containers to be managed across multiple Docker Engine daemons. Docker tool commands (`node` and `swarm`) providing native __clustering__ functionality; turns a group of Docker Engines into __a single _virtual_ Docker engine__. Docker manages swarms using the [_Raft Consensus Algorithm_](https://en.wikipedia.org/wiki/Raft_(computer_science) "Wikipedia").  
 - [__Swarm Mode__](https://docs.docker.com/engine/swarm/key-concepts/)    
    Can start/stop services, and modify them, while they remain online. A __Swarm Manager__ (node) is specified (or elected thereafter) as the __Leader__ of all __Swarm Managers__ (_Followers_). The Swarm (consensus algorithm) [requires a Quorum](https://docs.docker.com/engine/swarm/raft/) (N/2 +1) of managers agreeing on the state of the swarm. So, for example, having two managers instead of one doubles the chance of losing quorum; always keep an ___odd number___ of Swarm Managers.
    - __Activation__, "`docker swarm init`", __enables__ additional `docker` tool commands: `docker node` | `service` | `stack` | `secret`  
        - Swarm Data @ `UDP/4789`
        - Swarm Commands @ `TCP/2377`
        - Swarm Control Plane @ `TCP/2376` (_Never use this._)
            - All communication between Docker Engines of the swarm occurs thereof. Nodes of a swarm may be scattered across Cloud vendors. ___Vendorless!___
    - Orchestration and its security is handled internally by Swarm Manager(s). There is no external database or authority involved in any of it.
        - Each Manager posesses the complete Swarm state, for greater reliability and speed.  
        - Worker/Manager nodes can switch roles, per API.
        - Node-to-Node Communication Protocols; presuming multi-node swarm, not single-node swarm mode.
        - Swarm Managers communicate with each other securely using __Raft__ protocol, which is __strongly consistent__, forming a self-sufficient __Quorum__;  no external dependencies. 
        - Workers communicate with each other using __Gossip__ protocol, which is __eventually consistent__, but very fast. 
        - Manager to Worker communication is across the control plane (`TCP/2376`) per [__gRPC__ protocol](https://en.wikipedia.org/wiki/GRPC "Wikipedia"); binary data; uses HTTP/2 for transport; Protocol Buffers as its <dfn title="Interface Definition Language">IDL</dfn>.

## [Networking](https://docs.docker.com/v17.09/engine/userguide/networking/ "docs.docker.com/...UserGuide/Networking") | [Configure](https://docs.docker.com/network/ "docs.docker.com/network") | [Reference Architecture](https://success.docker.com/article/networking) | [Tutorials](https://docs.docker.com/engine/tutorials/networkingcontainers/)
_Batteries included, but removable._  
`docker network ls`  
`ip addr show`   

### Container Network Drivers/Options   

1.  __Bridge Networking__ a.k.a. Single-host Networks   
`docker0`; original/default; `Driver: bridge` Layer 2 network; isolated, even if on same host; routes through NAT firewall on host IP; external comms only by port mapping, host IP-to-IP. Containers connect to Docker __bridge__ (`docker0`) network by ___default___.    
`docker run --name web -p 1234:80 nginx`   
`docker port web` 
2. __Overlay Networking__ a.k.a. Multi-host Networks  
Layer 2 network spanning multiple hosts, e.g., connects all containers across all nodes of the swarm.  
`docker network create ...`  
    - Control Plane encrypted by default.  
    - Data Plane encrypted per cmdline option  
    `docker network create --opt encrypted ...`
3. MACVLAN  
Each container (MAC) given its own IP Address on an existing VLAN. Requires promiscuous mode on host NIC; typically not available @ cloud providers. 
4. IPVLAN    
- Experimental; does not require promiscous mode.  
- Containers on the same network communicate __with each other__ sans port mapping (`-p`). External ports closed by default; put frontend/backend on same network for inter-container comms. Best practice is to create a new virtual network for each app.  E.g.,  
    - Network `web_app_1` for `mysql` and `php`/`apache` containers.  
    - Network `api_1` for `mongo` and `nodejs` containers.  
- Containers can attach to more than one virtual network (or `none`).  
- Network is selectable and configurable:  
    - "`--network none`"  adds container to a container-specific network stack.
    - "`--network host`" adds container to host’s network stack; to use host IP instead of virtual networks'. 

List selected keys of "`docker inspect ...`" across all networks, 
refactored into another *valid* JSON object: 

```bash
docker network ls -q |xargs docker network inspect $1 \
    |jq -Mr '.[] | select(.Name != "none") | {Name: .Name, Driver: .Driver, Address: .IPAM.Config}' \
    |jq --slurp .

```
- [`docker.network.ls.inspect_jq.filtered.json](docker.network.ls.inspect_jq.filtered.json)

### Network Services

- __DNS Server__ &mdash; Containers are ephemeral, making their IP addresses unstable/unreliable, so containers are identified by DNS name, not IP addresses. That  is, ___container names are host names___.  _Docker uses embedded DNS to provide service discovery for containers running on a single Docker Engine and tasks running in a Docker Swarm. [Docker Engine has an internal DNS server](https://success.mirantis.com/article/networking#dockernetworkcontrolplane) that_ ___provides name resolution to all of the containers on the host___ _in user-defined bridge, overlay, and MACVLAN networks. Each Docker container (or task in Swarm mode) has a DNS resolver that forwards DNS queries to Docker Engine, which acts as a DNS server. Docker Engine then checks if the DNS query belongs to a container or service on network(s) that the requesting container belongs to. If it does, then Docker Engine looks up the IP address that matches a container, task, or service's name in its key-value store and returns that IP or service Virtual IP (VIP) back to the requester._ NOTE:
    - ___Only non-default networks automatically run a DNS serer.___ The default network (`bridge`) does not, unless declared. For that, use `docker run ... --link ...` to add container-to-container link, but it is easier and _better to simply create a new network_ and use that.  
- __Service Discovery__  &mdash; Every service is named, and registered with Swarm DNS, so every service task (container) gets a DNS resolver that forwards lookups to that Swarm-based DNS service. Services of a swarm are reachable from any swarm node, even if node is not running the service. 
- __Load Balancing__ &mdash; A benefit of Service Discovery is that every node in the Swarm knows about every service therein; any exposed port (-p `HOST:CNTNR`) on any node of a service is replicated on all nodes in the Swarm, and so Swarm does load balancing of incomming traffic (Ingress load balancing), and DNS-based load balancing on internal traffic.
    - [UCP Internal Load Balancing](https://success.mirantis.com/article/networking#dockernetworkcontrolplane "mirantis.com") &mdash; Internal load balancing is instantiated automatically when Docker services are created. When services are created in a Docker Swarm cluster, they are automatically assigned a Virtual IP (VIP) that is part of the service's network. The VIP is returned when resolving the service's name. Traffic to that VIP is automatically sent to all healthy tasks of that service across the overlay network. This approach avoids any application-level load balancing because only a single IP is returned to the client. Docker takes care of routing and equally distributing the traffic across the healthy service tasks. To see the VIP:
        ```bash
        # Create an overlay network called mynet
        $ docker network create -d overlay mynet
        a59umzkdj2r0ua7x8jxd84dhr

        # Create myservice with 2 replicas as part of that network
        $ docker service create --network mynet --name myservice --replicas 2 busybox ping localhost
        8t5r8cr0f0h6k2c3k7ih4l6f5

        # See the VIP that was created for that service
        $ docker service inspect myservice
        ...

        "VirtualIPs": [
                        {
                            "NetworkID": "a59umzkdj2r0ua7x8jxd84dhr",
                            "Addr": "10.0.0.3/24"
                        },
        ]
        ```
    - DNS Round Robin (RR) mode @ `--endpoint-mode dnsrr` 
        - Test; RR is a kind of cheap load balancing; multiple hosts responding to same DNS name, per aliasing.  
            ```bash
            # run two aliased RR-test servers 
            docker run -d --net 'net1' --net-alias 'foo' elasticsearch:2
            docker run -d --net 'net1' --net-alias 'foo' elasticsearch:2
            # Get IP & DNS of the two per nslookup; delete cntnr upon exit (--rm)
            docker run --rm --net net1 alpine nslookup 'foo'      # Alpine image contains nslookup
            Name:      foo
            Address 1: 172.20.0.2 foo.net1
            Address 2: 172.20.0.3 foo.net1
            # curl, repeatedly, to see random host select/response per Docker's RR scheme
            docker run --rm --net 'net1' centos curl -s foo:9200    
            # CentOS image contains curl
            ```
            - `elasticsearch:2` image chosen because it generates random host name for itself
            - `alpine` image chosen because it contains `nslookup`
            - `centos` image chosen because it contains `curl`

#### @ Swarm Mode | [Control Plane](https://success.mirantis.com/article/networking#dockernetworkcontrolplane "Mirantis.com")

_Docker supports_ ___IPSec encryption___ _for overlay networks between Linux hosts out-of-the-box. The Swarm & UCP managed IPSec tunnels encrypt network traffic as it leaves the source container and decrypts it as it enters the destination container. This ensures that your application traffic is highly secure when it's in transit regardless of the underlying networks._


- __Overlay__; `--driver overlay`   
    - Supports multi-host networks; container-to-container __comms across all nodes of the swarm__. All Tasks (containers) forming all Services running across all nodes (VMs) can access each other; uses a combination of local Linux bridges and VXLAN to overlay container-to-container comms over physical network infra.
- __Docker Routing Mesh__  :: @ __Docker CE__  ([Swarm External L4 Load Balancing](https://success.mirantis.com/article/networking#dockernetworkcontrolplane "mirantis.com"))
    - Transport Layer (L4) __Load Balancer__ (Stateless) Assigns Virtual IP addresses (VIPs) to swarm services, mapped to their DNS (name), and so handles the physical node routing. Load balances per Swarm Service, across their Tasks (containers).
- __HTTP Routing Mesh__ (__HRM__)  :: @ __Docker EE__ only  ([UCP External L7 Load Balancing](https://success.mirantis.com/article/networking#dockernetworkcontrolplane "mirantis.com"))
    - Application Layer (L7) __Load Balancer__ (Stateful) Load balances across services; all services can share same port..   

#### @ Swarm Mode | [Data Plane](https://success.mirantis.com/article/networking#dockernetworkcontrolplane "Mirantis.com")

Extend Docker's ___IPSec encryption___ to the data plane. (The control plane is automatically encrypted on overlay networks.)  _In a hybrid, multi-tenant, or multi-cloud environment, it is crucial to ensure data is secure as it traverses networks you might not have control over._

- Enable data-plane encryption:
    ```bash
    docker network create -d overlay --opt encrypted=true $_NTWK_NAME
    ``` 

_At services thereunder, when two tasks are created on two different hosts, an IPsec tunnel is created between them and traffic gets encrypted as it leaves the source host and decrypted as it enters the destination host. The Swarm leader periodically regenerates a symmetrical key and distributes it securely to all cluster nodes. This key is used by IPsec to encrypt and decrypt data plane traffic. The encryption is implemented via IPSec in host-to-host transport mode using AES-GCM._


## Tools 

- [`docker` (Ref)](https://docs.docker.com/engine/reference/commandline/cli/ "docs.docker.com/engine"); __Docker Engine CLI__. The main tool; handles image builds and container creations. Two modes: Single-host and `swarm`.  

- [`docker-machine` (Ref)](https://docs.docker.com/machine/reference/ "docs.docker.com/machine") is a tool to create and manage VMs for multi-node Swarm(s). Creates Docker hosts (nodes) anywhere; local/cloud; OS/distro [per driver](https://docs.docker.com/machine/drivers/); installs Docker thereon, and configures `docker` CLI (per VM, per shell). 
- [`docker-compose` (Ref)](https://docs.docker.com/compose/reference/overview/ "docs.docker.com/compose") is a combination of (dev) tool and YAML config file for defining and running multi-container Docker applications. `docker-compose.yml` is the __default filename__, but can be any name.   
    ```bash
    docker-compose up
    docker-compose down
    docker-compose -f 'foo-manifest.yml'
    ```
    - Manage all containers with one command
    - Configure relationships between containers  
    - Run commands on multiple containers at once 
    - Set/save "`docker run`" settings in YAML  
    - Create one-liner startup command for a development environment.
    - The tool itself (`docker-compose`) is _used mainly for local test and development_. In production, in __Swarm__ mode (`v1.13+`), the Docker Engine CLI tool (`docker`) uses the YAML file (`docker-compose.yml`) directly.

## Images :: [Docker Hub](https://hub.docker.com/explore/ "hub.docker.com")  

The [Explore](https://hub.docker.com/explore/) tab lists all Official images [(`docker-library`)](https://github.com/docker-library/official-images/tree/master/library "GitHub")

1. `[ACCTNAME/]REPONAME`  
1. `REPONAME`
    - The "`official`" images are further distinguished by their `REPONAME` sans  "`ACCTNAME/`" prefix. These are high quality images;  well documented, versioned (per `:TAG`), and widely adopted. E.g., &hellip;
        ```bash 
        # The official Nginx image; "1.11.9" is the Tag (version).
        docker pull nginx:1.11.9  
        ```  

The ubiquitous "`latest`" __Tag__ specifies a _latest_ (stable) published version of a repo; not necessarily the latest commit. E.g., &hellip;  

```bash
docker pull nginx:latest
# ... equivalent ...
docker pull nginx         
``` 

### Tags / Tagging

`ACCTNAME/REPONAME:TAG`  

The entirety, "`USER/NAME:TAG`", _is often referred to as "tag"._  

One image may have many tags. To change the image tag, and optionally rename an image, &hellip; 

```bash
docker image tag SRC_IMG[:TAG-old] TGT_IMG[:TAG-new]
```
- Absent TAG, the Docker daemon defaults to search for "`latest`". 

#### The `TAG` of `<none>` 

```bash
☩ di
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
gd9h/prj3.api-amd64   dev                 ce6b736c74c1        2 hours ago         31.2MB
gd9h/prj3.pwa-amd64   dev                 414f405cee2c        19 hours ago        21.7MB
gd9h/prj3.rds-amd64   dev                 b1350eefb9b9        2 days ago          31.3MB
gd9h/prj3.exv-amd64   dev                 96594cfee5fa        2 days ago          17.5MB
postgres              <none>              baf3b665e5d3        4 days ago          158MB
postgres              12.6-alpine         c88a384583bb        3 weeks ago         158MB
golang                1.15.8              7185d074e387        4 weeks ago         839MB
nginx                 1.19.3-alpine       4efb29ff172a        5 months ago        21.8MB
```
- The `<none>` tag (and image) is a Docker daemon pull per YAML declaration. Here, though the YAML declares `image:`&nbsp;`postgres:12.6-alpine`, a newer image ___of the same tag___ exists at Docker Hub repo, and so the Docker engine pulls that, tagging it `<none>`, and builds the container therefrom. This is common at Swarm nodes, whereof we update images yet maintain the same tag (`dev`).
    - [@ Postgres repo](https://hub.docker.com/_/postgres "Docker Hub"), the most recent three-dot version is `9.6.21-alpine` (`13.2-alpine` is newest as of 2021-04-05). It is not known if they changed their versioning or if all newer are simply too immature (update too often).

### Image Layers / Cache

Images are built of filesystem changes and metadata. The image build process implements the __Union FS/Mount__ concept ([per `OverlayFS`](https://en.wikipedia.org/wiki/OverlayFS)); files and directories of __separate file systems__ are ___transparently overlaid___, forming a single coherent file system.  

__Each image layer__ is __hashed__ and __cached__, and so can be incorporated into multiple images; _successive layers are nothing but changes (diff) from the prior layer_. This strategy accounts for the radically lighter weight of images relaitve to virtual machines (VMs). Changes to a container are recorded per __Copy on Write__ (CoW) process.


__Local__ image __cache__ @ Docker Engine host:   

- `/var/lib/docker/STRG_DRVR/DIGEST/{merged,diff,work}`  
    - E.g., `/var/lib/docker/overlay2/5adcbf...01a016/{merged,diff,work}`  

Docker references each layer, and each image containing them, by __multiple__ unique identifiers (digests and other IDs), per Docker tool and context.   Additionally, the image manifest file (JSON) itself is hashed, and that too is an image reference.  

___This is the source of much confusion___, since the image digests reported on `pull` or `run` don't match those reported elsewhere; while "`IMAGE ID`" at "`docker image ls`" is something else entirely. And there is no easy way to match a cached layer (folders &amp; files) to its Registry (layer digest).

##### Example: `docker image inspect 'alpine'`  

- `Id` (The local reference)   
    - @ `[{Id:...}]`  
        - `"Id": "sha256:196d12...84d321"`  
- `RepoDigests`  
    - @ `[{"RepoDigests":"..."}]`  
        - `"alpine@sha256:621c2f...af5528"`
- `Config` digest  
    - @ `[{"Config":{"Image":"..."}}]`  
        - `"Image": "sha256:836dc9...0e59b7"`
- Local image __cache__ dir(s):    
    - @ `[{"GraphDriver":{"Data":{"MergedDir":"...","UpperDir":"...","WorkDir":"..."}}}]`   
        - `/var/lib/docker/overlay2/5adcbf...01a016/{merged,diff,work}`  
        - The directories (digests) __change__ per cache (`pull`)

### Publishing  

`docker login`  
Stores auth key @ `~/.docker/config.json`,  ___until___ &hellip;  
`docker logout`  

`docker push ACCTNAME/REPONAME:TAG`

## Image Registry (v2)  

The image resistry is integral to Docker's tools and its entire container ecosystem. Docker's [Distribution](https://github.com/docker/distribution "GitHub") toolset handles this; _"&hellip; pack, ship, store, and deliver content."_  

- The storage system is based on [Content-addressable Storage](https://en.wikipedia.org/wiki/Content-addressable_storage) (CAS)  
- __Image reference__ format: `REGISTRY/REPO/IMAGE`  
    - But this is actually an [Image Manifest](https://docs.docker.com/registry/spec/manifest-v2-2/) reference.  
An "_image_" is but a sum of immutable Union filesystem (FS) ___layers___, any one of which may be in many images; a one-to-many mapping.
- Each __Docker image__ has __two Registry references__, necessarily. Both are unique identifiers (`sha256`, so `hex64`):
    1. [__Content__ digest](https://docs.docker.com/registry/spec/api/#content-digests)  
The __hash of the [Image Manifest](https://docs.docker.com/registry/spec/manifest-v2-2/)__; a JSON file containing the hash of each layer. These are __not__ the "`IMAGE ID`" shown per "`docker image ls`", nor such ___local___/___cache___ references.
    2. __Distribution__ digest    
    The __hash of a compressed image layer__ (_tarball_ of its Union FS/Mount; folders and files). These are __not__ the "_image_" references shown per "`docker pull ...`", nor such ___Resistry___ references.
        - No easy way to match layer ID with its location at host dir; digests which change per pull, &hellip; @ `/var/lib/docker/STRG_DRVR/DIGEST/{merged,diff,work}`  
- __Pull__ image per URL request:   
`GET /v2/NAME/manifests/{TAG|DIGEST}`  
- <def title="HTTP 200|404">__Test__</def> for existence of __image__:  
`HEAD /v2/NAME/manifests/{TAG|DIGEST}`  
- <def title="HTTP 200|404">__Test__</def> for existence of a __layer__:  
`HEAD /v2/NAME/blobs/DIGEST`
- Two Docker Registries (Docker-maintained):  
    1. [Docker Hub](https://hub.docker.com/)
    2. [Docker Trust Registry](https://docs.docker.com/ee/dtr/) (DTR), on-prem, requiring Docker EE   

### [Docker Registry](#registries "Cloud or Local") 

## Build Process 
`image => container => image => container => ...`  

Images are __immutable__; containers are modified _while running_; new images are built of prior images and changes thereto while running. This is iterated as necessary &hellip;

- _Declaratively_, [per `Dockerfile`](https://docs.docker.com/engine/reference/builder/).   
- _Imperatively_, [per `docker`](https://docs.docker.com/engine/reference/commandline/commit/) CLI commands.  

    ```bash
    # Imperatively                        Dockerfile equivalent
    docker run [OPTIONS] IMAGE            # FROM (base image/layer)
    docker exec [OPTIONS] CONTAINER CMD   # CMD  (add pkg, etc)
    docker commit [OPTIONS] CONTAINER     # FROM (this new layer)
    ```
    - It can be argued that "_imperatively_" / "_declaratively_" is more lingo than actual; regardless, there's a mapping between `docker` CLI commands/flags and `Dockerfile` statements.

## [`Dockerfile`](https://docs.docker.com/engine/reference/builder/ "@ docs.docker.com") | [Best Practices](https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/ "2019 @ blog.docker.com")

A Dockerfile is the _recipe_ for an image build; the instruction set; has its own language/syntax/format. Each _"stanza"_, `FROM`, `ENV`, `RUN`, &hellip; is an image layer; each layer is downloaded, hashed, and ___cached___, so future builds (per mod) are fast, especially so if layered judiciously; __order__ is __important__; frequently modified layers placed below (after) those infrequently modified; any content change (e.g., per `COPY`) breaks the cache at that layer, and affects subsequent layers.  

```dockerfile
# Base; every image must have ... 
FROM alpine:3.8
ENV NGINX_VERSION 1.13.6-1~stretch 

# Chain places all at one cacheable layer; 
# Remove unncecssary dependencies & pkg-mgr cache
RUN apt-get update \
    && apt-get -y install --no-install-recommends ... \
    && rm -rf /var/lib/apt/lists/*

# Docker handles logging; need only map output ...
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# open ports 80 & 443 (to other containers @ bridge network) 
EXPOSE 80 443  
# ... map to host port(s) per run option ... -p|-P 

# Change working directories; use instead of RUN cd ...
WORKDIR /usr/share/nginx/html
# Copy from host to container 
COPY . .
# Copy dir to dir (from host to container)
# Any changes to the files being copied will break the cache, 
# so copy ONLY WHAT IS NEEDED.
COPY index.html index.html

# Volume; outlives container; must manually delete; UNNAMED ONLY !
VOLUME /the/volume/path/at/container

# Must run command/script @ cntnr launch 
# (may be embedded in FROM stmnt)
ENTRYPOINT ["entrypoint.sh"]        
# then this; overridden on any arg @ `docker run ... IMAGE`
CMD ["command","param1","param2"]  
# or default param(s) for ENTRYPOINT command or script
CMD ["param1","param2"]   
# ... JSON Array syntax    
```

## [Storage  &mdash; Data in containers](https://docs.docker.com/storage/storagedriver/#images-and-layers)   
Such data is destroyed upon container deletion (`rm`); survives  `stop`/`start` only. Files created inside a container are stored on a _thin_ __writable container layer__ _on top of_ its read-only image layers.  
- Difficult to access from outside the container.
- Requires a (kernel process) driver to manage the Union filesystem.  

#### [Storage Driver](https://docs.docker.com/storage/storagedriver/select-storage-driver/) a.k.a. Graph Driver (older) a.k.a. Snapshotter (newer)

- A container driver that (unpacks and) maps the (pulled) Image layers to local host storage, handles the container's writable ([CoW](https://docs.docker.com/storage/storagedriver/#the-copy-on-write-cow-strategy)) layer. The R/W performance of these drivers is poor across all host (backing) filesystems and block storage devices. (Containers are best stateless.)
    - `overlay2` [for `xfs`](https://docs.docker.com/storage/storagedriver/overlayfs-driver/#prerequisites) or `ext4` host FS; an [OverlayFS](https://en.wikipedia.org/wiki/OverlayFS) driver;   
    Docker's __default__ container storage driver.  
    - `devicemapper` for `direct-lvm` host block-storage device; depricated. is POSIX compliant and supports SELinux, but is slower.
    - `btrfs` and `zfs` for such host FS.
    - `aufs` for Ubuntu 14.04 and older, and Docker 18.06 and older.  
    - `vfs` is experimental 

## [Storage &mdash; Data Volumes](https://docs.docker.com/storage/ "docs.docker.com/storage")

__Separation of Concerns__  
Immutable design patterns treat containers as ephemeral, if not entirely stateless,  and so _persistent_ a.k.a. _unique_ data best resides __outside the container__.   
    
__Data Volumes__ a.k.a. Volumes   
Docker offers 3 options for __persistent container storage__, which is to say storage __outside the container__. All mount some kind of host (or remote) storage __as a path at the container__. [Each has use cases.](https://docs.docker.com/storage/#good-use-cases-for-volumes "docs.docker.com").

- [Volumes](https://docs.docker.com/storage/volumes/)   
A __Docker-managed object__; storage at the host mounted as a path at the container; `/var/lib/docker/volumes/NAME/_data` . At [DfW/DfM](# "Docker for Windows / Docker for Mac"), volumes are created at the Docker VM, not at the host. ([SSH into Docker VM](https://www.bretfisher.com/getting-a-shell-in-the-docker-for-windows-vm/)); can specify a volume declaratively, in `Dockerfile`, or per `docker` CLI, as a runtime parameter.   

    ```bash
    docker volume create $NAME 

    docker run ... -v $NAME:$CNTNR_PATH  
               ... -v foo:/app
               ... --mount source=foo,target=/app
               # ... creates new volume if NAME (foo) not exist
    
    # Volume location @ host ...
    ls /var/lib/docker/volumes/$NAME/_data
    ```
- @ DfW host, all volumes are within `%ProgramData%\DockerDesktop\vm-data\DockerDesktop.vhdx` (~`5 GB`)
- __New volume created__ if `NAME` not exist, even on `run`, so __no warning__ if typo.
- Multiple containers can share the same volume.
- Pre-populate; if new (empty) volume, then any pre-exising files @ container path (mount) are copied to the volume,and so can be made available to any other container.  
- Decouples host configuration from container runtime.  
- Host can be remote; cloud provider.
- Custom drivers and labels available if prior to `run` ...   
`docker volume create --driver $_DRVR --label $_LABEL`   

- [Bind Mounts](https://docs.docker.com/storage/bind-mounts/)  
__Host filesystem__ directory or file mounted as a path at the container; The original Docker mechanism for handling persistent data;

    ```bash
    docker run ... -v $HOST_PATH:$CNTNR_PATH  
               ... -v $(pwd):/app 
               ... -v //c/path:/app   # @ Windows
               --- -v ./relpath:/app  # relative paths okay
               ... --mount type=bind,source="$(pwd)",target=/app
    ```

    - Share configuration files between host and container. DNS resolution for Docker containers is per mount of  host `/etc/resolv.conf` into each container.

- [__`tmpfs`__ mounts](https://docs.docker.com/storage/tmpfs/)  
__Host system-memory__ (Linux only) mounted as a path at the container; never written to host filesystem.  

    ```bash
    docker run ... --tmpfs $CNTNR_PATH
               ... --tmpfs /app
               ... --mount type=tmpfs,destination=/app
    ```

    - Store non-persistent, in-memory-only data.  
    - Useful to deal with security or performance issues.  

### Named volumes 

`docker container run ... -v NAME:/cntnr_path`  
Volumes survive container deletion,yet contain no meta regarding whence the volume came; `docker volume ls` ... merely lists per ID; no other info, even @ `inspect`.  Hence __Named Volumes__.

## [Swarm Mode](https://docs.docker.com/engine/swarm/ "docs.docker.com/engine/swarm") [(`SwarmKit`)](https://github.com/docker/swarmkit "GitHub")

Container orchestration; Docker's clustering solution; a secure Control Plane; all handled internally. Swarm Managers use Raft (algo+protocol+database).

- v1.12+ (2016) SwarmKit  
- v1.13+ (2017) Secrets and Stacks
- Orthogonal to existing docker tools
- Not enabled by default; enabled by command:   
`docker swarm init`  
    - Launches PKI and security automation
    - Root Signing Certificate created
    - Cert issued for 1st Manager node
    - Join Tokens are created
    - Raft Concensus database created
    - Replicates logs amongst Managers via TLS 
- New `docker` CLI commands upon Swarm Mode enable:  
    - `docker swarm|node|service|stack|secret`

## [Services](https://docs.docker.com/engine/swarm/services/)  

In Swarm Mode, application components are replicated, and distributed  across the nodes,  which communcate through the [overlay network](https://docs.docker.com/network/overlay/#operations-for-all-overlay-networks). Each instance of the replicated component is a Task. The sum of all identical tasks are a Service. So, applications are deployed, per component, as Services.  

### `docker service create [OPTIONS] IMAGE [COMMAND] [ARG...]`

### `docker service update [OPTIONS] SERVICE`

## [Stacks](https://docs.docker.com/docker-cloud/apps/stacks/)
Production-grade Compose.
### `docker stack deploy -c "app1.yml" "app1"`
### `docker stack ls`
### `docker stack ps "app1"`
### `docker stack services "app1"`

## [Configs](https://docs.docker.com/engine/swarm/configs/)

```bash
echo "This is a config" |docker config create foo-bar -
```

__Stored as file @ container: `/`__

```bash
cat /foo-bar
```

- [Nginx/TLS](https://docs.docker.com/engine/swarm/configs/#advanced-example-use-configs-with-a-nginx-service) example

## [Secrets](https://docs.docker.com/engine/swarm/secrets/)

```bash
echo "This is a secret" |docker secret create foo-bar -
```

__Stored as file @ container: `/run/secrets/`__ 

```bash
cat /run/secrets/foo-bar
```

- Swarm mode only.
- Stored encrypted outside container.
- Is _unencrypted_ inside the container.
- Generic string or binary < 500 KB  
    - `KEY:VAL` pair per file or string
        - `docker secret create KEY FILE`   
        (stored @ host drive)  
        - `echo VAL | docker secret create KEY -`   
        (stored @ bash history)  
    `docker service create ... --secret KEY -e VAL_FILE=PATH ...`  
    Note that "`*_FILE`" is keyword to trigger file-method (versus treating it as a string).
- @ Swarms, not containers.
- @ Windows containers, clear text stored @ container’s root disk.
- Docker 1.13+, Swarm Raft db is encrypted on disk on Manager nodes. Control Plane is TLS encrypted + Mutual PKI Auth.
- Secrets are stored in the Swarm and assigned to Services; only assigned their Services have access.
- App sees as file on disk, but exist only as in-memory filesystem.  
    - `/run/secrets/SECRET1_NAME`  
- `docker-compose` has workaround to use secrets sans Swarm; not really secure, but facilitates local development.
- [@ `docker-compose.yml` (YAML)](https://docs.docker.com/engine/swarm/secrets/#use-secrets-in-compose)  

## CI/CD :: Dev &#x21d4; Test &#x21d4; Prod 
- DevOps on an app (Swarm Cluster) per __set of Compose files__.  
    - Dev environment (Local)  
    `docker-compose up`  
    - CI environment (Remote)  
    `docker-compose up`  
        - `docker-compose.override.yml` &hellip; is __automatically added__ per `docker-compose up` .
    - Procution (Remote)  
    `docker stack deploy`

            $ tree -L 1 ./swarm-stack-3
            .
            ├── Dockerfile
            ├── docker-compose.override.yml 
            ├── docker-compose.prod.yml
            ├── docker-compose.test.yml
            ├── docker-compose.yml
            ├── psql-fake-password.txt
            ├── sample-data
            └── themes

- @ Test (`up`)   

    ```bash
    docker-compose -f docker-compose.yml \
        -f docker-compose.test.yml up -d  
    ```

- @ Prod (`config`)  

    ```bash
    docker-compose -f docker-compose.yml \
        -f docker-compose.prod.yml config > "out.yml" 
    ``` 

    - Combines the files.  
    - The "`extends:`" option is another method; not yet stable; all this is new.  

<a name="registries"></a>

## [Docker Hub](https://hub.docker.com/)  

- One free public acct; one free __private__ registry (repo) 
- Webhooks to automate; CI/CD, where Docker Hub notifies downstream per repo change.
- Organizations; like github
- Automated Builds  
Use "Create Automated Build" (Menu select) if automating/integrating with GitHub;do NOT use the big "Create Repository" button. 
    - Creates CI path for automatic builds per code commit. A kind of reverse Webhook.

### CVE :: Security Vulnerabilities @ [CVEdetails.com](https://www.cvedetails.com/google-search-results.php?q=postgres&sa=Search)

## [Docker Store](https://store.docker.com) ($) 

1. Docker SW.  
2. Quality 3rd party images.

## [Docker Cloud](https://cloud.docker.com) ($) 

- CI/CD and Server Ops  
- Web-based Swarm Orchestration GUI; integrates with popular cloud providers  
- Automate image build/test/deploy  
- Security scanning for known vulnerabilities  
    - US Government (DHS); US Cert Program `CVE` (Common Vulnerability and Exposures). Tracks vulnerabilities.  

## [SaaS Registries](https://github.com/veggiemonk/awesome-docker#registry "List @ Awesome Docker [GitHub]") (3rd Party)

## [Docker Registry 2.0](https://hub.docker.com/_/registry/)  ([GitHub](https://github.com/docker/distribution))  

The code, an HTTP server, that runs Docker Hub; _"The Docker toolset to pack, ship, store, and deliver content."_ A __web API and storage system__ for storing and distributing Docker images. 

The de facto standard for running a __local (private) container registry__. Not as full-featured as Docker Hub; no web GUI; basic auth only. Storage drivers support local, S3, Azure, Alibaba, GCP, and OpenStack Swift.

- [Docker Classroom](https://training.play-with-docker.com/ "Training")

- Private/Local [Registry Setup](https://training.play-with-docker.com/linux-registry-part1/ "Docker registry for Linux Part 1") Topics
    - [Secure the Registry with TLS](https://training.play-with-docker.com/linux-registry-part2/ "Training :: Tutorial/Assignment")
    - Maintain via [Garbage Collection](https://docs.docker.com/registry/garbage-collection/) (The Docker document there is utterly useless.)
    - Enable Hub caching via "`--registry-mirror`" to conserve bandwidth on large-scale clusters/builds

## Run a Private [Registry Server](https://distribution.github.io/distribution/about/deploying/)

- Run the Distribution [registry](https://hub.docker.com/_/registry/ "@ Docker Hub :: Docker Registry :: Official repo") image on __default port 5000__  
- Sans HTTPS, it allows only `localhost` (`127.0.0.0/8`) traffic.  
- For _remote_ self-signed TLS, enable "insecure-registry" engine.  

#### Build it with persistent storage (`-v`) at host.  

```bash
docker container run -d -p 5000:5000 --name 'registry' \
    -v $(pwd)/registry-data:/var/lib/registry 'registry' 
    # Bind Mount
```

#### Set Registry Domain 
```bash
_REPO='127.0.0.1:5000'  # localhost:5000
```

#### Test it

```bash
# Pull/Tag/Push   
docker pull hello-world
docker tag hello-world ${_REPO}/hello-world
docker push ${_REPO}/hello-world
# Delete cached container & image
docker image remove hello-world
docker container rm $_CONTAINER
docker image remove ${_REPO}/hello-world
docker image ls  # verify it's gone (from cache) 
# Pull it from local registry 
docker pull ${_REPO}/hello-world
# View the image @ cache
docker image ls
# Run it (delete cntnr on exit)
docker run --rm ${_REPO}/hello-world
```

#### Query it
```bash
# List per name, in JSON
curl -X GET $_REPO/v2/_catalog
# or (same)
curl $_REPO/v2/_content 
# List tags of an image
curl $_REPO/v2/$_IMG/tags/list
# inspect (full info)
docker inspect $_REPO/ubuntu:18.04
```

#### Delete Image(s)/Repo(s) 

- Nope. Docker doesn't like people running their own repos, apparently. There are a few articles on how to delete repos/images, but it's ridiculously complex and tedious. Docker's [Garbage Collection](https://docs.docker.com/registry/garbage-collection/) page is utterly useless.

### Private Docker Registry with Swarm 
- Works the same due to Routing Mesh; all nodes can see `127.0.0.1:5000`  
- All nodes pull from repo, not from each other, hence Docker Registry is integral to Docker workflow.  

Run a Registry @ [Play with Docker](https://labs.play-with-docker.com/)  

Templates > "5 Managers and no workers".

```bash
docker node ls
docker service create --name registry --publish 5000:5000 registry
docker service ps registry
```

Pull/Tag (`127.0.0.1:5000`)/Push the `hello-world` image again, then view the Registry catalog @ "`5000`" URL (endpoint); root is empty, but root`/v2/_catalog` shows Registry content per JSON. 

## Advance Configs

```bash
# @ TLS
$ docker run -d \
    --restart=always \
    --name registry \
    -v "$(pwd)"/certs:/certs \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -p 443:443 \
    registry:2

# @ TLS +Basic Auth
$ docker run -d \
    -p 5000:5000 \
    --restart=always \
    --name registry \
    -v "$(pwd)"/auth:/auth \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    -v "$(pwd)"/certs:/certs \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    registry:2

# @ Swarm Service +TLS
$ docker node update --label-add registry=true node1
$ docker secret create domain.crt certs/domain.crt
$ docker secret create domain.key certs/domain.key
$ docker service create \
    --name registry \
    --secret domain.crt \
    --secret domain.key \
    --constraint 'node.labels.registry==true' \
    --mount type=bind,src=/mnt/registry,dst=/var/lib/registry \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/run/secrets/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/run/secrets/domain.key \
    --publish published=443,target=443 \
    --replicas 1 \
    registry:2


```

### Load-Balancer Considerations

- Required Headers

```ini
Docker-Distribution-API-Version: registry/2.0
X-Forwarded-Proto 
X-Forwarded-For
```

#### Distribution Recipes : [NGINX](https://distribution.github.io/distribution/recipes/nginx/)


### &nbsp;
