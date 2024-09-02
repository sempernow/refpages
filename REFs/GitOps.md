# DevOps/[GitOps](https://opengitops.dev/ "OpenGitOps.dev") `v1.0.0`

## Overview

GitOps is __an operational framework__ that takes DevOps best practices used for application development such as version control, collaboration, compliance, and __CI/CD__, and applies them to infrastructure automation. GitOps consists of __Infrastructure as Code__ (IaC), configuration management (__CM__) by Git, <def title="Provide everything below microservices">__platform engineering__</def>, and continuous integration and continuous delivery (CI/CD).  

DevOps is about automation across the lifecycle of an application.
GitOps extends that with disciplined methods &mdash;Git as the Source of Truth (SoT) 
&mdash;across all layers of all components, 
from infra to services, with the goal of repeatable, 
verifiable deployment states.

### Principles

1. __Declarative__  
    A system managed by GitOps must have its desired state expressed declaratively.
2. __Versioned and Immutable__  
    Desired state is stored in a way that enforces immutability, versioning and retains a complete version history.
3. __Pulled Automatically__  
    Software agents automatically pull the desired state declarations from the source.
4. __Continuously Reconciled__  
    Software agents continuously observe actual system state and attempt to apply the desired state.

### Results

- A standard workflow for application development.
- Increased security for setting application requirements upfront.
- Improved reliability with visibility and version control through Git.
- Consistency across clusters and their environments.

## Environments

__Upon what infrastructure__ does the app AKA workload AKA service run?

- __Cloud__ : 3rd-party vendor, typically virtual; SDNs, VMs, &hellip;
- __On-prem__ : Self managed; physical and/or virtual
- __Bare-metal__ : OS and app on physical machine, sans hypervisor/virtualization, 
  _regardless_ of whether on-prem or in cloud.
- __Edge__ : More than just a reference to gateway router(s); an environment and topology. 
  Distributed architectures and practices for __processing data closer to where it is generated or consumed__.
    - __Computing__: 
        - Proximal to Data : Located close to the source of data, such as IoT devices, sensors, or users. This proximity allows for faster data processing and reduced latency.
        - Distributed Architecture : Deploying smaller, localized data centers or computing resources that work together with centralized cloud services. This creates a distributed architecture where certain tasks are handled at the edge, while others are processed in the cloud or a central data center.
        - Real-Time Processing : For applications that require real-time processing and quick decision-making, such as autonomous vehicles, industrial automation, and smart cities.
        - Reduced Bandwidth Usage : Only the relevant or processed data needs sent to central data center/cloud, reducing amount of data egress.
    - __Environment__:
        - Edge Devices : Sensors, IoT devices, smart appliances, &hellip;
            - To generate or consume data.
        - Edge Servers or Mini Data Centers : small-scale computing resources in retail stores, factories, telecom towers, vehicles, &hellip; deployed close to edge devices 
            - To process and analyze data locally.
        - Edge Gateways : Routers and other devices.
            - To aggregating data from various edge devices and sometimes perform initial processing before forwarding data to central servers or the cloud.

## Tools | [CNCF Landscape](https://landscape.cncf.io/)

- Videos
    - [DevOps Toolkit](https://www.youtube.com/watch?v=tgwxMfIsLJY "YouTube")
    - [__eBPF__ Cilium](https://www.youtube.com/@eBPFCilium/videos "YouTube : eBPFCilium")
- __Service Catalog__ : UI of IDP : built/maintained 
  by GitOps/DevOps vendor/admin, not by end users.
    - Port : SasS only
    - [Backstage.io](https://backstage.io/) : Build Developers' Portals (IDP)
    - [Crossplane.io](https://www.crossplane.io/ "crossplane.io") @ [GitHub](https://github.com/crossplane)  
        - Programmable Control Plane, Controllers, APIs
        - Embed IaC tooling such as Terraform, Helm, Ansible,
          which converts IaC to Cloud-vendors' API requests.
- __IaC__ : __Service Management__ : Provision/Configure:  
    - [__Kubernetes__](https://kubernetes.io/docs/home/ "Kubernetes.io") : 
      Cluster API, Crossplane, &hellip;  
      K8s is a __universal Control Plane__
    - [__Terraform__](https://registry.terraform.io):  
        Declarative provisioning of cloud infrastructure 
        and policies (per-vendor modules), 
        and managing Kubernetes resources.
    - [__Ansible__](https://docs.ansible.com/ansible/latest/index.html):  
        Provision and configure infrastructure, OS/packages, 
        and application software in any environment.
        A comprehensive, versatile automation tool 
        allowing for both declarative and imperative methods.
    - Pulumi : IaC in any language
- __IaC__ : __Workloads__
    - Application Management (K8s Manifests)
        - [__Timoni.sh__](timoni.sh) (Uses CUE)  
          Distribution and Lifecycle Management for Cloud-Native Applictions
        - [__Helm__](https://helm.sh/docs/helm/helm/ "helm.sh/docs/"):  
            A package manager for Kubernetes, Helm can be used to package applications into charts, 
            which are then version-controlled in Git repositories. Helm charts can be deployed using GitOps tools like Flux or Argo CD.
        - [__Kustomize__](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/ "Kubernetes.io/docs/"):  
            Generate, customize, and/or otherwise manage Kubernetes objects using files (YAML) stored in a Git repo. 
            It's integrated into `kubectl` and can be used with other GitOps tools to manage deployments. 
            Use to modify Helm chart per environment.
        - [KCL](https://www.kcl-lang.io/docs/user_docs/getting-started/intro "kcl-lang.io") @ [GitHub](https://github.com/kcl-lang/kcl/)
        An open-source constraint-based record & functional language mainly used in configuration and policy scenarios. 
        Writtin in Rust, Golang, Python.
        - [CUE](https://cuelang.org/ "cuelang.org")
        - [Pkl](https://pkl-lang.org/ "pkl-lang.org")  
        Configuration that is Programmable, Scalable, and Safe
    - CI : Glorified Chron Job
        - [Dagger](https://docs.dagger.io/quickstart/daggerize) functions: 
        Pipeline agnostic functions that run in CI/CD pipeline of any vendor.
        - Tekton
        - Argo Workflows
        - Jenkins
        - GitHub Actions
        - GitLab CI
    - CD : Application Lifecycle
        - [__Flux__](https://github.com/fluxcd/flux2)  
            A tool to automatically sync Kubernetes clusters/applications
            with their configuration sources, across their lifecycles.
        - [__Argo CD__](https://github.com/argoproj/argo-cd):   
            Visualize (Web UI) and manage the lifecycle of Kubernetes applications;
            supports automated or manual syncing of changes.
            - Argo Workflows + Argo Events required = CD 
                - Argo Events > Tekton Events
- [__Authn__/__Authz__](https://kubernetes.io/docs/concepts/security/controlling-access/ "Kubernetes.io")
    - [__Authentication__](https://kubernetes.io/docs/reference/access-authn-authz/authentication/ "Kubernetes.io") (Authn) :  
        -  __Two types of subject__ : K8s provides for binding either type to roles for cluster access:
            1. __`ServiceAccount`__ : K8s __object__ declaring a non-human entity (subject). E.g., a Pod.
            1. A **user** and/or **group** : K8s __concept__ of human entity (subject).  
            Though K8s has neither user nor group objects, 
            it searches for these subjects in certificates and tokens, 
            and provides for binding them to roles.
        - __Two scenarios__:
            1. Clients authenticating against the K8s API server
                - The **two most common methods**: 
                    - [X.509 certificate issued by K8s CA](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user "Kubernetes.io") 
                    - Token (JWTs) generated by an OIDC provider, e.g., __Dex__ or __Keycloak__, which may proxy an upstream Identity Provider (__IdP__) such as AD. K8s [recognizes the subject](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"), e.g., by token claims of user/group, or  `ServiceAccount` having K8s `cluster.user`. 
                - Regardless of method, __identities that match__ a (`Cluster`)`RoleBinding` __are authorized for access__ according to the associated (`Cluster`)`Role`.
            1. Users authenticating at web UI against an application running on the cluster.
                - Token (JWTs) generated by an OIDC provider, which may be same as other scenario, to enable Single Sign On (SSO), since OIDC is just an extention of [OAuth2](https://oauth.net/2/). 
        - [Authentication Plugins](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authentication-strategies "Kubernetes.io")
            - Static Token file
                - Bearer token
                - Service Account token
            - X.509 certificates (TLS)
            - [Open ID Connect (OIDC) token](https://kubernetes.io/docs/reference/access-authn-authz/rbac/ "Kubernetes.io")
            - Authentication proxy
            - Webhook
    - [__Authorization__](https://kubernetes.io/docs/reference/access-authn-authz/authorization/ "Kubernetes.io") (Authz) | Modules/[Modes](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules "Kubernetes.io")   
    Regardless of authentication method, 
    K8s can implement Role-based Access Control ([RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/ "Kubernetes.io")) model 
    against subjects ([known by request attribute(s)](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"))
    using a pair of K8s objects for each of the two scopes of K8s API resources (`api-resources`):
        1. Namespaced (`Deployment`, `Pod`, `Service`, &hellip;)
            - `Role` : Rules declaring the allowed actions (`verbs`) upon `resources` scoped to APIs (`apiGroup`).
            - `RoleBinding` : Binding a subject (authenticated user or ServiceAccount) to a role.
        1. Cluster-wide (`PersistentVolume`, `StorageClass`, &hellip;)
            - `ClusterRole`
            - `ClusterRoleBinding`
- __Logging__ : Cluster-level logging, AKA __Log Aggregation__ AKA __Unified Loggging__, so that logs survive their (ephemeral) generator, be that of any host or container process.
    - __Elastic stack__ : to collect, store, query, and visualize log data. Composed of:
        1. [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html "Elastic.co") backend : A search &amp; analytics engine, with an integral storage scheme. Elasticsearch uses a __distributed document-oriented database model__ where it stores data in indices. These __indices are persisted__ to disk in a data directory, typically managed by Elasticsearch nodes. The storage and retrieval of data are handled internally by Elasticsearch using its own mechanisms, such as the [Lucene](https://en.wikipedia.org/wiki/Apache_Lucene "Wikipedia") library for indexing and searching.
        1. [Kibana](https://www.elastic.co/guide/en/kibana/current/introduction.html "Elastic.co") frontend :  Web UI optimized for query/view &mdash;*Explore, Visualize, Discover* &mdash;logs from Elasticsearch.
        1. __Logs Collector__/__Forwarder__ : This is the data-processing pipeline that ingests logs from applications, and then transform (normalize) and forwards them to provide for Unified Logging. This is __the stack's workhorse__, yet oddly external to the stack namesake and core (Elasticsearch/Kibana). Solutions are provided by various projects, many entirely separate from Elasticsearch (the company):
            - [Logstash](https://www.elastic.co/logstash "Elastic.co") : Elastic's native solution
            - [Fluentd](https://www.fluentd.org/architecture "Fluentd.org") : Data collector (not limited to logs, metrics and tracing).
                - [Fluent Bit](https://fluentbit.io/) : 
                *Lightweight forwarder for Fluentd*.
                - [Fluent Operator](https://github.com/fluent/fluent-operator "GitHub"), formerly "FluentBit Operator" : 
                    *Manage Fluent Bit and Fluentd the Kubernetes way*.
        - [ECK (Elastic Cloud on K8s) Operator](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html "Elastic.co")  @ [Air-gap environment](https://chatgpt.com/share/5e27759e-6741-4c72-aed6-1458f3562eba "ChatGPT.com") for Elasticsearch and Kibana. 
            - Requires separate installation of a log collector/forwarder
        - [OpenSearch](https://opensearch.org/docs/latest/about/ "OpenSearch.org") : FOSS fork of Elastic stack (Elasticsearch/Kibana)
            - [Data Prepper](https://opensearch.org/docs/latest/data-prepper/) : Data collector designed specifically for OpenSearch; focus is on observability data, particularly logs, metrics, and traces. 
    - [Grafana Loki](https://grafana.com/oss/loki/) | [`grafana/loki`](https://github.com/grafana/loki/ "GitHub") ([Install](https://grafana.com/docs/loki/latest/setup/install/)) : "*Prometheus, but for logs*". A lightweight alternative to Elastic stack.
        - __Does not provide full-text indexing__ of logs; indexes only the logs' metadata (__labels__).
        - No viable installation method is available (2024-08), contrary to project claims. 
- __Observability__ : Distributed __Tracing__ and __Metrics__
    - [Prometheus](https://prometheus.io/ "Prometheus.io") : TSDB and monitoring system optimized for telemetry (metrics and tracing). 
    The defacto standard, but does not scale, and has horrible alerts (Alertmanager). So popular that projects provide workarounds to manage scaling. Provision using [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator-1) :
        - [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator "GitHub") :   
        The bare operator ([`bundle.yaml`](https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml "GitHub"))
        - __`kube-prometheus`__ : *A collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide &hellip; __end-to-end Kubernetes cluster monitoring__ with Prometheus using the Prometheus Operator.* 
            - The Prometheus Operator
            - Grafana
            - Highly available Prometheus
            - Highly available Alertmanager
            - Prometheus `node-exporter`
            - Prometheus `blackbox-exporter`
            - Prometheus Adapter for Kubernetes Metrics APIs
            - `kube-state-metrics`; replacment for `metrics-server`
            - Install using one of two very similar projects:
                - Manifest method : [prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus "GitHub") 
                - Helm method : [prometheus-community/kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#kube-prometheus-stack "GitHub") 
        - [Thanos](https://thanos.io/ "Thanos.io") @ [GitHub](https://github.com/thanos-io/thanos "GitHub") : Prometheus HA + long-term storage ([MinIO](https://min.io/docs/minio/kubernetes/upstream/operations/installation.html "Min.io")) : CNCF project; can "seamlessly upgrade" on top of an existing Prometheus deployment.
    - [Grafana](https://grafana.com/) : Web UI : Dashboards
        - [Grafana Tempo](https://github.com/grafana/tempo) : Tracing backend; scales and integrates with Jaeger, Zipkin, and OpenTelemetry; fixes Jaeger shortcommings
    - [Jaeger](https://www.jaegertracing.io/docs/1.18/opentelemetry/ "JaegerTracing.io") : Tracing collector that integrates with OpenTelemetry
        - [Jaeger Operator](https://www.jaegertracing.io/docs/1.60/operator/ "JaegerTracing.io") @ [GitHub](https://github.com/jaegertracing/jaeger-operator "GitHub")
            - Requires [`cert-manager`](https://cert-manager.io/docs/)
    - [OpenTelemetry](https://opentelemetry.io/docs/collector/) (OTEL)
      Vendor-agnostic tracing library; 
      app library (almost all languages covered) for generating traces
        - [OpenTelemetry Operator](https://opentelemetry.io/docs/kubernetes/operator/ "OpenTelemetry.io") @ [GitHub](https://github.com/open-telemetry/opentelemetry-operator "GitHub") : 
        K8s Operator to manage collectors ([OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector "GitHub")) and auto-instrumentation of workloads using OTEL libraries.
    - [VictoriaMetrics](https://victoriametrics.com/products/open-source/) : 
      TSDB & Monitoring Solution (as a Service); 
      compatible with Prometheus.
    - [Inspektor-Gadget.io](https://www.inspektor-gadget.io/) : 
       eBPF-based CLIs (gadgets)
        ```bash
        kubectl gadget deploy
        # Monitor all network traffic of a namespace
        kubectl gadget advise network-policy monitor -n $ns -o network.$ns.log.json
        # Processes in containers of Pods
        kubectl get snapshot process -n $ns
        # Inspect top (processes) of a namespace
        kubectl gadget top file -n $ns
        # Trace requests into services of a namespace
        kubectl gadget trace tcp -n $ns
        ```
        - Expanding BPF usage from single nodes to across the entire cluster layers
        - Maps low-level Linux resources to high-level Kubernetes concepts integration
        - Use stand-alone or integrate into your own tooling, e.g., Prometheus metrics.
            - Several tools utilized it already, e.g., Kubescape
    - Robusta : Alerting 
    - Komodor : Troubleshooting
    - Pixie : All in one
    - Groundcover : All in one
- __Netowrking__
    - External Load Balancer
        - `kube-vip` ([GitHub](https://github.com/kube-vip/kube-vip "GitHub.com") | [Docs](https://kube-vip.io/ "kube-vip.io")): 
          K8s Virtual IP and Load Balancer (LB) for both control plane and services 
          for On-prem, Edge, Bare-Metal, &hellip;
            - [Architecture](https://kube-vip.io/docs/about/architecture/)
    - CNI
        - [Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)
        - [Cilium](https://cilium.io/) : eBPF
    - Ingress
        - [Istio](https://istio.io/)
            - Sidecar Proxy 
        - [Traefik](https://traefik.io/traefik/) : Automatically wires routes per Service discovery
        - [Ingress-Nginx](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/)
        - [Cilium](https://cilium.io/) : eBPF
        - Consul
    - [K8s Gateway API](https://gateway-api.sigs.k8s.io/implementations/#gateways)
        - [Traefik](https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/)
    - Service Mesh
        - Istio
        - Traefik : Automatically wires routes per Service discovery
        - [Linkerd](https://linkerd.io/) : Service Mesh (East-West) : mTLS + Load Balancing between services  
            - Sidecar Proxy (written in Rust).
        - Kuma
        - Consul
    - Service Discovery
        - etcd : K8s cluster
        - Consul : Multi-cluster
- __Database__
    - Managed
        - Aiven 
    - KubeBlocks : K8s Operator : Supports many databases
    - [TiKV](https://github.com/tikv/tikv) : distributed, and transactional key-value database. FOSS. CNCF Graduated project.
    - [Cassandra](https://github.com/apache/cassandra) : NoSQL distributed database. Apache/CNCF project.
    - [NiFi](https://github.com/apache/nifi) @ [GPTchat](https://chatgpt.com/share/0935e21e-30dd-445b-97b3-1d8ed46782ce) : A system to ingest, process and distribute data (from anywhere); automated and managed flow of information between systems; suited for complex data integration, ETL processes, real-time data flows, and scenarios requiring detailed data lineage and tracking. Apache/CNCF project.
    - [CloudNativePG](https://cloudnative-pg.io/) (CNPG) : K8s Operator covering full lifecycle of a highly available PostgreSQL database cluster with a __primary/standby architecture__, using native __streaming replication__. A CNCF project.
    - Atlas Operator : Schema
- __Security__
    - Scanning
        - Trivy
        - [Kubescape.io](https://kubescape.io/)  
          Risk analysis, security compliance, and misconfiguration scanning.
    - Threat Detection and Remediation
        - Falco 
        - KubeArmor
    - Policies
        - Kyverno
        - Kubernetes Validating/Admission Policy
    - Secrets
        - [External Secrets Operator](https://external-secrets.io/latest/)  
          Pull/Push secrets to/from K8s
        - [Teller](https://github.com/tellerops/teller) : Secret manager for developers
        - [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), 
        - [SOPS](https://github.com/getsops/sops), 
        - [Vault](https://github.com/hashicorp/vault) for encrypting secrets that are stored in Git. 
        This ensures that sensitive information is securely managed.
    - Signing
        - Sigstore Cosign
        - Notary
    - Certificates
        - [cert-manager](https://cert-manager.io/ "cert-manager.io") : _&hellip;obtain certificates from &hellip; public &hellip; as well as private Issuers &hellip;, and ensure the certificates are valid and up-to-date, and &hellip; renew certificates at a configured time before expiry._
- __Misc__
    - Charm : Library and Tools

## Methods

- __Declarative Configuration__:  
    Use declarative configurations (YAML files) for all resources and store them in a Git repository. 
    This approach ensures that the desired state of your cluster is version-controlled and auditable.
    - __Branching Strategies__:  
        [Trunk-based](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development) 
        rather than [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) 
        to manage different environments (development, staging, production) or to handle feature development and releases.
- __Pull Request Workflow__:  
    Use pull (merge) requests (PR/MR) to manage changes to the Kubernetes configuration. 
    This allows for code review, approval processes, 
    and automated testing before changes are merged and applied.
- __Automated Deployment__:  
    Implement CI/CD pipelines that automatically apply changes from Git to your Kubernetes cluster. 
    This could involve testing changes in a staging environment before promoting them to production.
- __Disaster Recovery__:  
    Regularly back up your Git repository and Kubernetes cluster state. 
    Ensure you have a process in place for restoring from backups in case of a disaster.
    
## Configuration 

- __Repository Structure__:  
    Organize your Git repository in a way that reflects your deployment environments and application structure. 
    This could involve separate directories for each environment and application.
- __Secrets Management__:  
    Use tools like [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), 
    [SOPS](https://github.com/getsops/sops), 
    or [Vault](https://github.com/hashicorp/vault) for encrypting secrets that are stored in Git. 
    This ensures that sensitive information is securely managed.
- __Monitoring and Alerting__:  
    Integrate monitoring and alerting tools to track the health of your deployments and the Kubernetes cluster. 
    [Prometheus](https://prometheus.io/docs/introduction/overview/) and [Grafana](https://grafana.com/) 
    are commonly used tools that can be managed via GitOps.
- __Policy Enforcement__:  
    Use policy-as-code tools like Open Policy Agent (OPA) or [Kyverno](https://github.com/kyverno/kyverno) 
    to enforce policies on your Kubernetes clusters. 
    Store policies in Git to apply them consistently across your environments.
- __Security Scanning__:  
    Implement security scanning of your Docker images and Kubernetes configurations as part of your CI/CD pipelines. 
    Tools like [Trivy](https://trivy.dev/ "trivy.dev"), Clair, and KubeLinter can be integrated into your workflows.






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

