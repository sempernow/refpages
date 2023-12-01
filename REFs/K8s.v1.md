# Kubernetes [`k8s`]
## [Overview](https://kubernetes.io/docs/home/?path=users&persona=app-developer&level=foundational) | [Tools](https://kubernetes.io/docs/reference/tools/ "kubernetes.io/docs/...") | [GitHub](https://github.com/kubernetes "Kubernetes repo") | [Kubernetes.io](https://kubernetes.io/) | [Wikipedia](https://en.wikipedia.org/wiki/Kubernetes)  

- [___Why?___](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/#why-do-i-need-kubernetes-and-what-can-it-do "Kubernetes.io Docs/Concepts")   
    - The need to scale effectively/efficiently is what spurred containers.  
    - The need to manage/orchestrate container deployment is what spurred kubernetes.   
- [___What?___](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/ "Kubernetes.io Docs/Concepts")   
A system for running many _different_ application components over many _different_ machines (nodes). A set of master processes, typically on one node, directing a set of minion processes that are cloned across each node constituting their cluster, to __control__ cluster __state__.  
    - __Declarative__ (though imperative capable) directives are communicated to the master, whereof control logic determines how to best implement those directives; how to change the __current state__ of the cluster to the __desired state__. 
    - Born @ Google, of [Borg](https://ai.google/research/pubs/pub43438) + [Omega](https://www.nextplatform.com/2015/05/05/google-omega-to-become-part-of-borg-collective/) projects
    - [Open Source](https://github.com/kubernetes "Kubernetes repo") @ 2015
    - Written in [Go/Golang](https://golang.org/)
    - IRC, @kubernetesio, [slack.k8s.io](http://slack.k8s.io/)

## [Concepts](https://kubernetes.io/docs/concepts/) and [Architecture](https://kubernetes.io/docs/concepts/architecture/)  ([GitHub](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/architecture.md#kubernetes-design-and-architecture "GitHub/kubernetes/.../architecture"))

- Node (VM)
    - VM in which Pod(s) are managed, per Kubelet.
- Pod 
    - Atomic unit of scheduling.
    - Holds one or more containers.
- Service
    - Stable endpoint handler for a group of (ephemeral) pods functioning as one, e.g., load balancer (egress) function. 
- Deployment 
    - Defines desired (end) state for the Scheduler.

## [Objects](https://kubernetes.io/docs/concepts/#kubernetes-objects) in the K8s __API__
- Basic 
    - __`Pod`__  
    - __`Service`__  
    - `Volume`  
    - `Namespace`  

- Controllers (higher level abstraction) 
    - __`Deployment`__  
    - `ReplicaSet`  
    - `StatefulSet`  
    - `DaemonSet`  
    - `Job`  

## [Control Plane](https://kubernetes.io/docs/concepts/#kubernetes-control-plane) :: Master & Nodes (Minions)
Maintains a record of all Objects; runs continuous control loops to manage object state,   
responding to changes in the cluster, working from the current state toward the desired state.  

### [Components](https://kubernetes.io/docs/concepts/overview/components/)  

- __Masters__  
Responsible for maintaining the cluster's desired state; __a collection of processes__ managing the cluster state; typically all on one node, which is also called the Master; can be replicated for availability and redundancy; `kubectl` tool communicates with it (@ `kube-apiserver`). 
- [Master Components](https://kubernetes.io/docs/concepts/overview/components/#master-components):
    - __`apiserver`__ a.k.a. `kube-apiserver` a.k.a. "Master" &mdash; The front-end to the Control Plane. The only exposed master component. Exposes (REST) API @ port `443`. Consumes/Validates JSON (Manifest files).  
    - __Cluster Store__ (__`etcd`__) &mdash; [`etcd` key/value (NoSQL) store](https://github.com/etcd-io/etcd "GitHub/etcd-io/etcd") by [CoreOS](https://coreos.com/etcd/). "Source of Truth" for the cluster. Stores cluster state and config. Distributed, consistent, watchable. _The only stateful component of the control plane._
    - __Controller__ (`kube-controller-manager`) &mdash; The controller of all controllers.  [Some controllers have cloud-provider-spcecific dependencies](https://kubernetes.io/docs/concepts/overview/components/#cloud-controller-manager). Maintains __desired state__.  
    - __Scheduler__ (`kube-scheduler`) &mdash; Watches `apiserver` for new pods.  Assigns work to nodes: Affinity/anti-affinity, constraints, resources, ...; One comms path from Minions to Master ([secure](https://kubernetes.io/docs/concepts/architecture/master-node-communication/#cluster-to-master)):   
    - `kubelet` to `apiserver` per `HTTP` (localhost:`443`) &mdash; Two comms paths from Master to Minions ([insecure](https://kubernetes.io/docs/concepts/architecture/master-node-communication/#master-to-cluster "kubernetes.io/docs/... MITM attack")):  
        1. `apiserver` to (node) `kubelet`.  
        2.  `apiserver` to nodes, pods, and services thru `kube-proxy`.  

- [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)  (VM) a.k.a. __Minions__ a.k.a. Workers  
Machines (virtual or physical) containing one or more containers; Worker (Minion) machines running the applications and cloud workflows. One or more pods, each with one or more containers packaged together as a unit. Each node contains the __services__ necessary to run __pods__ controlled by Master (`kube-apiserver`). [Node Components](https://kubernetes.io/docs/concepts/overview/components/#node-components):  

    - [__`kubelet`__](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/architecture.md#kubelet "GitHub/kubernetes/.../architecture") a.k.a. "Node"   
    The main K8s agent; processes enforcing the __container__ `PodSpecs`  
    The most important/prominent __controller__  
    The primary implementer of Pod and Node APIs  
    Registers (node) with cluster  
    Watches/Reports to `apiserver`  

    - __Container Engine__ a.k.a. [Contaner Runtime](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/architecture.md#container-runtime "GitHub/kubernetes/.../architecture")   
    Pluggable/agnostic; [any OCI compliant](https://github.com/opencontainers): `Docker`, `rkt`, `runc`, ...  
    Performs container mgmnt; pulls images and runs containers.   


    - [__`kube-proxy`__](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)  
    K8s networking @ Node; manages __Pod IP__ addresses.  
    Programs `iptables` (Linux firewall) rules.  
    __One IP per Pod__ (shared by all its containers).  
    All containers in pod share a single IP.  
    Load balances across all pods in a __service__.  

- [Addons](https://kubernetes.io/docs/concepts/overview/components/#addons)  
Pods and services that implement cluster features. 
    - [Cluster DNS](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/); a DNS Server; a required Addon.  
    - Web UI (Dashboard)   
    - &#8230;   

## [Working with Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/) 

- [Names & UIDs](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/)   
Identifier (string) of object, globally unique (per API).  
__Name__ is client-provided.  
__UID__ is auto-generated.

-  [Labels and their Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)   
(`label: foo` => `selector: foo`) are the core grouping primitive. __Labels tie Pods and Services together.__  

    - __Labels__  ("`labels:`") are _user-chosen_ `k-v` pairs; attached to objects, such as Pods, to specify identifying attributes; used to organize and to select subsets of objects; attached to objects either at creation, or subsequently added/modified; __labels are not unique__, except within the same object, so expect ambiguity within an application.  
    Thus the need for Selectors.

        ```yaml
        kind: Pod
        ...
        metadata:
          ...
          labels:            # Label
            component: web
        ```

    - [Label Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) ("`labels:`" vs. "`selector:`") are the core grouping primitive. The `k-v` pair specified under "`selector:`" identifies the target(s) so labeled at their "`labels:`". ___Selectors are required because labels are not unique.___

        - Two types
            - Equality-based Selectors; filtering by `key:value`. Matching objects should satisfy all the specified labels.
            - Set-based Selectors; filtering of keys according to a set of values.


        - Typically used by a __Service__ to __target__ a __set of Pods__.

        ```yaml
        kind: Service
        ...
        spec:
          ...
          selector:          # Selector
            component: web
        ```

## [Object Management](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/) 

- Declarative Model   
    - Control cluster per __Manifest__ (`YAML`) files

## [Workloads](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/ "kubernetes.io/docs/concepts/Workloads")

### [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 

- __Pod is the Atomic Unit__ of Scheduling/Scaling.  

    ```yaml 
    # Pod template
    apiVersion: v1
    kind: Pod
    metddata:
        name: hello-world
    spec:
        containers:
        - name: hello-ctr
        image: foo/bar-docker-ci:latest
        ports:
        - containerPort: 8080
    ```
    - One instance of an application or component thereof.
    - One running process on a cluster, with its own (unstable) IP address.  
    - One (or more, if tightly coupled) __container__(s).  
        - Defined in a Manifest (`YAML`) file.  
        - Declared (fed) to the Master (`apiserver`)  
        - Deployed to a node by Master's Scheduler. 
    - One IP per Pod  (Single Network Namespace)
        - 10.0.10.10:80    Main container  
        - 10.0.10.10:3000  Supporting container  
        - Everything in a pod shares the same cgroup limits, volumes, network, IPC namespaces, ...  
        - __Inter__-pod comms is per pod `IP:PORT`
        - __Intra__-pod comms is per `localhost:PORT`
- Deploying a Pod   
    - Directly by Pod Manifest file (`kind: Pod`)  
    - Inderectly by __Replication Controller__ (`ReplicaSet`). Depricated; seccessor is __Deployment__, a higher level abstraction.  
    - In production, pods are handled only indirectly, through a __Deployment__ (Controller). Pods are fungible; created and destroyed per scaling (`ReplicaSets`) and such, so __their address is unstable__. Hence the need for __Services__.  
- __Scaling is per pod__ (replicas), __not by adding more containers__ to a pod. What goes into any given pod is per app design; coupling considerations and such. __Multi-container pods__ are only for __complimentary__ containers or app services __requiring tight coupling__. E.g., Web server + Log scraper (_Main_ container + _Sidecar_ container).   

### [Controllers](https://kubernetes.io/docs/concepts/workloads/controllers/)

- [__Replication Controller__](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)  (Wraps Pods)   
`kind: ReplicationController`    
Higher-level abrstraction for deploying pods.  
Scalability / Reliability / __Desired State__ (Reconciliation loop).  

    ```yaml 
    # ReplicationController section
    apiVersion: v1
    kind: ReplicationController
    metddata:
        name: hello-rc
    spec:
        replicas: 5
        selector: 
            app: hello-world
        template:
        # Pod template section (embedded)
        ...
    ```

- [__Deployment__](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)   ([Wraps `ReplicaSet`/`ReplicationController`](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) )     
`kind: Deployment`  

     Higher level abstraction; configures `ReplicaSet`,   
     which is successor to `ReplicationController`.  
    - Simplifies rolling __updates__ and __rollbacks__; versioned rollbacks.  
    - Simplifies running multiple concurrent versions  
        - Blue-Green deployments
        - Canary releases

    __Declarative__; desired state is defined per Manifest file (YAML) or CLI command, and the  Deployment Controller changes __actual__ state to __desired__ state at a controlled rate.

    - New/Old version Replica Sets remain after (rolling)update/rollback, so rollback/update (reversion) is as simple as changing the version label.

-  StatefulSet &mdash; Manages Pods that are based on an identical container spec; pods created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling; operates under the same pattern as any other Controller: makes changes to attain desired state from current state.

- DaemonSet &mdash; Ensures that all (or some) Nodes run a copy of a Pod

- Job  &mdash; Creates one or more pods and ensures that a specified number of them successfully terminate; tracks the successful completions. When a specified number of successful completions is reached, the job itself is complete. Deleting a Job will cleanup the pods it created.

### [Configuration](https://kubernetes.io/docs/concepts/configuration/overview/)

- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)  
Securely store data inside a cluster; built-in and/or created.  

    - [Create](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets) per config (`YAML`) or `kubectl create secret ...`.


### [Services](https://kubernetes.io/docs/concepts/services-networking/service/)  (Networking) 

![Service - a stable IP+DNS+LoadBalancer](Services.png)

- __Hide multiple IPs behind a single IP (and DNS) address.__   
    -  __Stable/Reliable Endpoints__ for cluster-wide networking:  
    __IP + DNS Name + PORT__
        - Enables pod access; between pods and from outside the cluster.
        - Load balances across all pods in the service.
    - Identifies its pods by matching the manifest __Labels__; @ `Pod`, the `key:value` pair @ `label:` must match   @ `Service`, the `key:value` pair @ `selector:`    
        - Handles pod discovery and tracking of its pods, as they pop in and out of existence. 
- __Service Discovery__  
    - Best method is [Cluster DNS](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) (Addon); a DNS service; resolvable DNS names for services inside the cluster; registers (new) services; configures kubelets (nodes).  
    - Alternative is __Environment Variables__, but that is static and upon cluster creation.  

- [__`ServiceTypes`__](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types &mdash; Exposing services to the internet, a.k.a. "__Publishing__". Predecessor of __Ingress__, which is a higher-level abstration.  
    - `ClusterIP` &mdash; The Default; internal access only; exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. 

    - [`NodePort` (link)](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)  &mdash; Adds TCP or UDP port (`30000-32767`) to `ClusterIP`;  exposes container to outside world; for development ___only___.
        ```yaml
        spec:
          type: NodePort        # NodePort SERVICE (sub-type) MAINTAINs ...
          ports:
            - port: 3050        # <=> Access OTHER PODs 
              targetPort: 3000  # <=> Access SELF 
              nodePort: 31111   # <=> Access PUBLIC
            selector:
                app: hello-world # must match that of Pods
        ```
                       31111           3000                3050
            Public <=> kube-proxy => | NodePort | => Pod =(PORT#)=> container
                                     | Service  |          

    - [`LoadBalancer` (link)](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)  &mdash; Integrates `NodePort` with cloud-based load balancers. Legacy method to expose a Cluster to outside world; per Deployment (set of Pods); predates `Ingress`; connects to external load-balancer service, e.g., AWS ELB. ( [ELB-specific `LoadBalancer` configurations](https://kubernetes.io/docs/concepts/services-networking/service/#connection-draining-on-aws).) 
    - [`ExternalName` (link)](https://kubernetes.io/docs/concepts/services-networking/service/#externalname)  &mdash; Map a service to a DNS name.
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/#what-is-ingress) &mdash; A collection of rules that allow inbound connections to reach the cluster services. Ingress is the successor and higher-level abstraction to `ServiceTypes` (`LoadBalancer` etal).   
    - Ingress exposes a set of `Services` to the outside world:

                internet
                    |
               [ Ingress ]
               --|-----|--
               [ Services ]

     - See "[Studying the Kubernetes Ingress system](https://www.joyfulbikeshedding.com/blog/2018-03-26-studying-the-kubernetes-ingress-system.html)".  Requires an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-controllers), and are implemented __per cloud provider__, whereof __Routing rules__ are declared.   
    - @ GCP/GKE
        -  [`ingress-gce` (GLBC)](https://github.com/kubernetes/ingress-gce "GitHub/Kubernetes/ingress-gce"); the GCP managed Ingress Controller 
        - [`kubernetes-ingress`;](https://github.com/nginxinc/kubernetes-ingress "NGINX, Inc. @ GitHub") "NGINX Plus Ingress Controllers for Kubernetes" 
        - [`ingress-nginx`;](https://github.com/kubernetes/ingress-nginx "Kubernetes.io @ GitHub") "NGINX Ingress Controller for Kubernetes"
            - Setup per environment (local, GC, AWS, Azure)   
            - NGINX Ingress Controller :: [Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/) 
        - [`kops`/`ingress-nginx`](https://github.com/kubernetes/kops/tree/master/addons/ingress-nginx "GitHub/kubernetes/kops/ingress-nginx")
    - @ AWS  
        - [`kops`/`ingress-nginx`](https://github.com/kubernetes/kops/tree/master/addons/ingress-nginx "GitHub/kubernetes/kops/ingress-nginx")
            -  Alternative is to [use `LoadBalancer`](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws "ELB-specific configuration &ndash; kubernetes.io"); Elastic Load Balancer (ELB) 

### [Storage](https://kubernetes.io/docs/concepts/storage/) 

- [Volume](https://kubernetes.io/docs/concepts/storage/volumes/)   
A Kubernetes object for storing data at the pod level.
    -  Pod storage.  
    - __Does not survive the Pod__; survives container restarts.  

- [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (__PV__) 
    - Cluster storage located @ host.
    - Survives the Pod.

- [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) (__PVC__) 
    - Config for a PV.

        - Statically Provisioned PV  
            - Storage pre-provisioned by cluster administrator.
        - [Dynamically Provisioned PV](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/#background)
            - Storage provisioned by cluster users, on-the-fly.  
        
        - Access Modes 
            - ReadWriteOnce - R/W; 1 node  
            - ReadOnlyMany  - R; multiple nodes 
            - ReadWriteMany - R/W; multiple nodes


## [Deploy](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/)
- Production (Managed Solutions | DYI)  
    - Amazon EKS (Elastic Container Service for Kubernetes)  
    - Google GKE (Google Cloud Kubernetes Engine)  
    - DYI  

- Development (CLI tools)  
    - `minikube`   
        - Minikube is a single-node Kubernetes cluster on a local VM.  
        - The tool is the cluster manager; manages the VM (node) itself.  
        - Development (local) ONLY.  
        - Typically on Hyper-V or VirtualBox. 
            - It's a huge CPU/RAM hog, on Hyper-V (`vmmem.exe`), even if nothing is deployed.  
        
    - `kubectl`  
    _The `docker` tool for Kubernetes/Minikube_ 
        - Communcates with (client of) Master `apiserver`  
        - Can be configured as client for any (romote) Master, per `context`. 
        - For both __development__ and __production__  

    - References
        - [Minikube @ GitHub](https://github.com/kubernetes/minikube)
        - [Tools](https://kubernetes.io/docs/reference/tools/)
        - [Running Kubernetes Locally via Minikube](https://kubernetes.io/docs/setup/minikube/)
        - [Hello Minikube](https://kubernetes.io/docs/tutorials/hello-minikube/)
        - [Interactive Tutorials](https://kubernetes.io/docs/tutorials/)
        - [`minikube` commands](https://kubernetes.io/docs/setup/minikube/#managing-your-cluster "kubernetes.io/docs/setup/minikube/...")
        - [`kubectl` commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands "kubernetes.io/docs/reference/...")
        - [Web UI (Dashboard)](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

        - `kops` ([MD](kops.html "@ browser"))  
        Production-grade cluster @ cloud provider.  
        An alternative to provider-managed K8s.

        - [`kubadm` (manual Kubernetes install)](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/ "kubernetes.io")  
        Bootstrap a minimum viable Kubernetes cluster  
        that conforms to best practices.

## Install Minikube  ([MD](Minikube.Install.md "Minikube.Install.md") | [HTML](Minikube.Install.html "@ browser")) for Development (single-node cluster)
## References   

- [Get Started with Kubernetes on Win 10 using Hyper-V and Minikube](https://www.c-sharpcorner.com/article/getting-started-with-kubernetes-on-windows-10-using-hyperv-and-minikube/ "Jan 2018")   

- [Running your own Docker containers in Minikube for Windows](https://medium.com/@maumribeiro/running-your-own-docker-images-in-minikube-for-windows-ea7383d931f6 "Medium.com 2017")

- Others   
May 2018  https://www.marksei.com/minikube-kubernetes-windows/   
Jun 2018  https://learnk8s.io/blog/installing-docker-and-kubernetes-on-windows   

.
