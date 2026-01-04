# DevOps/[GitOps](https://opengitops.dev/ "OpenGitOps.dev") `v1.0.0` | [CNCF Landscape](https://landscape.cncf.io/ "Landscape.CNCF.io")

## Overview

DevOps is about automation across the lifecycle of an application.
GitOps extends that with disciplined methods 
&mdash;__Git__ as the single __Source of Truth__ (SoT) 
&mdash;across all layers of all components, 
from infra to services, with the goal of repeatable, 
verifiable deployment states.

GitOps is __an operational framework__ that takes DevOps best practices 
used for application development such as version control, collaboration, compliance and such, 
and applies them to __infrastructure automation__. 
GitOps consists of Infrastructure as Code (__IaC__), configuration management (__CM__) by Git, 
<dfn title="Provide everything below microservices; build an Internal Developer Platform (IDP) to assist your developers in their daily operations.">Platform Engineering</dfn>, 
and <dfn title="A development practice of pipelining an automated merge, build and test of incremental code changes that are recorded and otherwise controlled by immutable versioning">Continuous Integration</dfn> 
and <dfn title="A development practice of pipelining and automated release and deployment such that the process has visibility and feedback by all team members">[Continuous Delivery](Continuous-Delivery-process-diagram.png)</dfn> (__CI/CD__).  

## Why

Configuration Management.

__The number of configurations__ in a system with many options __grows exponentially__. For example, a system with `N` binary configuration options has `2^{N}` possible configurations. This exponential growth percipitates the __configuration explosion__ problem, where a system's behavior under all possible configurations is __untestable__. 

DevOps and GitOps use a combination of principles and practices, 
such as Configuration as Code (__CaC__), to mitigate the risk posed by the vast configuration space.

### Q: 

How many possible configurations are there for __3 hosts__, 
each having __6 services__, each having __6 parameters__, 
__each having only two possible settings__?

This scenario is an artificially simple infrastructure 
to steelman the argument *against* DevOps/GitOps/IaC.
So, let's see what we may see &hellip;

### A: 

1. **Parameters per service**: Each service has 6 parameters, 
    and each parameter has 2 settings. 
    So, the number of configurations for one service is:  
    `2^6 = 64`

2. **Services per host**: Each host has 6 services, 
    so the number of configurations for one host is:  
    `64^6` = `(2^6)^6` = `2^36` = `68,719,476,736`

3. **Total hosts**: There are 3 hosts, 
    so the total number of configurations is:  
    `(68,719,476,736)^3` = `(2^36)^3` = `2^108`

4. **Final calculation**: `(2^36)^3` = `2^108`

So, the number of possible configurations is:  
`324,518,553,658,426,726,783,156,020,576,256`  
(`~ 3.2 x 10^32`) 

That's many more than a trillion trillion possible configurations.  

More than the estimated number of stars in the Universe.
Not the galaxy. The entire Universe.

And only one of those is the one you want. 
All the others are some kind of misconfiguration. 

Do you like those odds?

DevOps/GitOps with its IaC/CaC is an upfront cost 
that pays dividends each time it is applied.
And the more your infa builds out, the larger those per-build dividends grow.

Conversely, absent these practices,
every stage of the build out is levied a tax dwarfing that of the prior stage. 
The resulting explosion of misconfigurations is merciless. 
It grinds down productivity along with morale,
and does so ever more as the project progresses.

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

## Methods

- __Declarative Configuration__:  
    Use declarative configurations (YAML files) 
    for all resources and store them in a Git repository. 
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

## Tools | [CNCF Landscape](https://landscape.cncf.io/)

- Videos
    - [DevOps Toolkit](https://www.youtube.com/watch?v=tgwxMfIsLJY "YouTube")
    - [__eBPF__ Cilium](https://www.youtube.com/@eBPFCilium/videos "YouTube : eBPFCilium")
- Cloud Wrappers
    - [LocalStack](https://www.localstack.cloud/) : Mocks cloud-vendor services locally. *Develop and test your AWS applications locally to reduce development time and increase product velocity. Reduce unnecessary AWS spend and remove the complexity and risk of maintaining AWS dev accounts.*
    - [CloudCraft](https://www.cloudcraft.co/) : 
      3D graphic and resource/cost model of a cloud infra
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
    - [Pulumi](https://www.pulumi.com/product/infrastructure-as-code/) : 
    IaC in any language, but pay per play platform interfacing to cloud vendors.
        - [sst](https://sst.dev/) Pulumi wrapper : 
          *Deploy everything your app needs with a single config.*
    - [__Terraform__](https://registry.terraform.io):  
        Declarative provisioning of cloud infrastructure 
        and policies (per-vendor modules), 
        and managing Kubernetes resources.
    - [__Ansible__](https://docs.ansible.com/ansible/latest/index.html):  
        Provision and configure infrastructure, OS/packages, 
        and application software in any environment.
        A comprehensive, versatile automation tool 
        allowing for both declarative and imperative methods.
    - [__SaltStack__](https://saltproject.io/ "Saltproject.io") | [ChatGPT](https://chatgpt.com/share/674cfd9f-6c54-8009-a84c-d824e1587fa0) Infrastructure automation and CM.
- __IaC__ : __Workloads__
    - Application Management (K8s Manifests)
        - [__K8s Operator__](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) Pattern   
        The goal of an Operator is to put operational knowledge into software. Operators implement and automate common Day-1 (installation, configuration, etc.) and Day-2 (re-configuration, update, backup, failover, restore, etc.) activities in a piece of software running in K8s, by integrating natively with K8s concepts and APIs. We call this a K8s-native application. Instead of treating an app as a collection of primitives (Pods, Deployments, Services , ConfigMaps, &hellip;) it's treated as a single object that only exposes the knobs that make sense for the application, extending the core K8s API with <dfn title="Custom Resource Definitions">CRD</dfn>s as needed to do so. 
            - [Operator Framework](https://operatorframework.io/)
                - [Operator Lifecycle Manager (OLM)](https://olm.operatorframework.io/)
            - [Mast](https://docs.ansi.services/mast/user_guide/operator/) : Ansible runner to build simple and lightweight K8s Operators
            - [Kopd](https://github.com/nolar/kopf)   (K8s Operator Pythonic Framework) : Framework and library for building K8s-operators
            - [kube.rs](https://kube.rs/)  : Rust client for K8
            - [kubebuilder](https://book.kubebuilder.io/) : Project for learning and building K8s API extensions
        - [__Helm__](https://helm.sh/docs/helm/helm/ "helm.sh/docs/"):  
            K8s package manager; version controlled and deployable using GitOps tools like Argo CD or Flux.
        - [__Kustomize__](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/ "Kubernetes.io/docs/"):  
            Generate, customize, and/or otherwise manage Kubernetes objects using files (YAML) stored in a Git repo. 
            It's integrated into `kubectl` and can be used with other GitOps tools to manage deployments. 
            Use to modify Helm chart per environment.
        - [__Timoni.sh__](timoni.sh) (Uses CUE)  
          Distribution and Lifecycle Management for Cloud-Native Applictions
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
        - __Argo Workflows__
        - Jenkins
        - GitHub Actions
        - GitLab CI
    - CD : Application Lifecycle
        - [__Flux__ CD](https://github.com/fluxcd/flux2)  
            - A tool to automatically sync K8s clusters/applications
            with their configuration sources (Git) across their lifecycles.
            - Supports automated deployments, where changes to the Git repo trigger updates in the Kubernetes cluster. 
            - Handles secret management and multi-tenancy.
            - __Flagger__ integration: Flux can be used together with Flagger for progressive delivery; advanced deployment strategies.
        - __Flagger__:
            - Automates the release process by gradually shifting traffic to the new version while measuring metrics and running conformance tests. 
              If anomalies are detected, Flagger can automatically rollback.
            - Designed for **progressive delivery** techniques like canary releases, A/B testing, and blue/green deployments.
            - Service-Mesh Integration: Used with service meshes like Istio, Linkerd, and others, 
              leveraging their features for traffic shifting and monitoring.
        - [__Argo CD__](https://github.com/argoproj/argo-cd):   
            - A declarative, GitOps continuous delivery tool for K8s. 
            Visualize (Web UI) and manage the lifecycle of K8s applications;
            supports automated or manual syncing of changes.
                - For CD, also need __Argo Workflows__ &amp; __Argo Events__ (preferred over Tekton Events)
            - Application Definitions, Configurations, and Environments: All these are declaratively managed and versioned in Git.
            - Automated Deployment: Argo CD automatically applies changes made in the Git repository to the designated Kubernetes clusters.
            - Visualizations and UI: Argo CD provides a rich UI and CLI for viewing the state and history of applications, aiding in troubleshooting and management.
            - Rollbacks and Manual Syncs: Supports rollbacks and manual interventions for syncing with Git repositories.
        - __Argo Rollouts__: Advanced deployment strategies like canary and blue/green. Similar to Flagger
- __Multi-tenancy__
    - [__vCluster__](https://github.com/loft-sh/vcluster "GitHub") Virtual clusters for better isolation than Namespace offers. OSS and Enterprise editions.
- __Logging__ : Cluster-level logging, AKA __Log Aggregation__ AKA __Unified Loggging__, so that logs survive their (ephemeral) generator, be that of any host or container process.
    - __Elastic stack__ : to collect, store, query, and visualize log data. 
        - Composed of:
            1. __Backend__ : [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html "Elastic.co") : A search &amp; analytics engine, with an integral storage scheme. Elasticsearch uses a __distributed document-oriented database model__ where it stores data in indices. These __indices are persisted__ to disk in a data directory, typically managed by Elasticsearch nodes. The storage and retrieval of data are handled internally by Elasticsearch using its own mechanisms, such as the [Lucene](https://en.wikipedia.org/wiki/Apache_Lucene "Wikipedia") library for indexing and searching.
            1. __Frontend__ : [Kibana](https://www.elastic.co/guide/en/kibana/current/introduction.html "Elastic.co") frontend :  Web UI optimized for query/view &mdash;*Explore, Visualize, Discover* &mdash;logs from Elasticsearch.
            1. __Agent__ : Collector/Forwarder of container logs : This is the data-processing pipeline that ingests logs from applications, and then transform (normalize) and forwards them to provide for Unified Logging. This is __the stack's workhorse__, yet oddly external to the stack namesake and core (Elasticsearch/Kibana). Solutions are provided by various projects, many entirely separate from Elasticsearch (the company):
                - [Logstash](https://www.elastic.co/logstash "Elastic.co") : Elastic's native solution
                - [Fluentd](https://www.fluentd.org/architecture "Fluentd.org") : Data collector (not limited to logs, metrics and tracing).
                    - [Fluent Bit](https://fluentbit.io/) : 
                    *Lightweight forwarder for Fluentd* for environments having limited resources 
                    - [Fluent Operator](https://github.com/fluent/fluent-operator "GitHub"), formerly "FluentBit Operator" : 
                        *Manage Fluent Bit and Fluentd the Kubernetes way*.
        - Stacks
            - [ECK Operator](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html "Elastic.co")  (Elastic Cloud on K8s) Contains only Elasticsearch and Kibana. Does not include any Collector/Forwarder (Fluentd, Logstash, &hellip;)
                - Deploy in [air-gap environment](https://chatgpt.com/share/5e27759e-6741-4c72-aed6-1458f3562eba "ChatGPT.com")  : 
            - __EFK Stack__ | [HowTo](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes "DigitalOcean.com") | [Helm](https://artifacthub.io/packages/helm/elastic/elasticsearch)
            - ELK stack : Logstash instead of Fluentd for log processing and aggregation. Logstash is more resource-intensive but offers more complex processing capabilities.
            - [OpenSearch](https://opensearch.org/docs/latest/about/ "OpenSearch.org") : FOSS fork of Elastic stack (Elasticsearch/Kibana)
                - [Data Prepper](https://opensearch.org/docs/latest/data-prepper/) : Data collector designed specifically for OpenSearch; focus is on observability data, particularly logs, metrics, and traces. 
    - [Grafana Loki](https://grafana.com/oss/loki/) | [`grafana/loki`](https://github.com/grafana/loki/ "GitHub") ([Install](https://grafana.com/docs/loki/latest/setup/install/)) : "*Prometheus, but for logs*". A lightweight alternative to Elastic stack.
        - __Does not provide full-text indexing__ of logs; indexes only the logs' metadata (__labels__).
        - No viable installation method is available (2024-08), contrary to project claims. 
- __Observability__ : Distributed __Metrics__ and __Tracing__
    - [Prometheus](https://prometheus.io/ "Prometheus.io") : TSDB and monitoring system optimized for telemetry (metrics and tracing). 
    The defacto standard, but does not scale, and has horrible alerts (Alertmanager). So popular that projects provide workarounds to manage scaling. Provision using [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator-1) :
        - [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator "GitHub") :   
        The bare operator ([`bundle.yaml`](https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml "GitHub"))
        - __`kube-prometheus`__ : *A collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide &hellip; __end-to-end Kubernetes cluster monitoring__ with Prometheus using the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator-1).* 
            - The Prometheus Operator
            - Grafana
            - Highly available Prometheus
            - Highly available Alertmanager
            - Prometheus `node-exporter`
            - Prometheus `blackbox-exporter`
            - Prometheus Adapter for Kubernetes Metrics APIs
            - `kube-state-metrics`; replacment for `metrics-server`
            - __Install using__ one of _two very similar projects_:
                - __`kube-prometheus`__  
                Manifest method : [`prometheus-operator/kube-prometheus`](https://github.com/prometheus-operator/kube-prometheus "GitHub") 
                - __`kube-prometheus-stack`__  
                Helm method : [`prometheus-community/kube-prometheus-stack`](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#kube-prometheus-stack "GitHub") 
                ChatGPT 5(See [k8s-vanilla-ha-rhel9](https://github.com/sempernow/k8s-vanilla-ha-rhel9 "GitHub : sempernow/k8s-vanilla-ha-rhel9"))
        - [__Thanos__](https://thanos.io/ "Thanos.io") @ [GitHub](https://github.com/thanos-io/thanos "GitHub") : Prometheus HA + long-term storage ([MinIO](https://min.io/docs/minio/kubernetes/upstream/operations/installation.html "Min.io")) : CNCF project; can "seamlessly upgrade" on top of an existing Prometheus deployment.
    - [__Grafana__](https://grafana.com/) : Web UI : Dashboards
        - [__Grafana Tempo__](https://github.com/grafana/tempo) : Tracing backend; scales and __integrates with OpenTelemetry__, Zipkin, and __Jaeger__; fixes Jaeger shortcomings.
    - [__Jaeger__](https://www.jaegertracing.io/docs/1.18/opentelemetry/ "JaegerTracing.io") : __Tracing__ collector that integrates with OpenTelemetry
        - [Jaeger Operator](https://www.jaegertracing.io/docs/1.60/operator/ "JaegerTracing.io") @ [GitHub](https://github.com/jaegertracing/jaeger-operator "GitHub")
            - Requires [`cert-manager`](https://cert-manager.io/docs/)
    - [__OpenTelemetry__](https://opentelemetry.io/docs/collector/) (OTEL)  
      Vendor-agnostic tracing library for generating traces.   
      Its app library covers almost all languages.
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
- __Streaming__/__Messaging__ : Run on __dedicated nodes__
    - [RabbitMQ](https://github.com/rabbitmq/rabbitmq-server) : 
     A widely used open-source message broker that supports multiple messaging protocols, including AMQP, [MQTT](https://mqtt.org/), and STOMP. It's known for its simplicity, ease of setup, and support for various messaging patterns like work queues, publish-subscribe, and routing. RabbitMQ is a good choice for IoT and other simpler, high-throughput messaging scenarios.
    - [Strimzi](https://strimzi.io/ "Strimzi.io") : Kafka on K8s : [`strimzi-kafka-operator`](https://github.com/strimzi/strimzi-kafka-operator "GitHub") : For production features such as rack awareness to spread brokers across availability zones, and K8s taints and tolerations to run Kafka on dedicated nodes. Expose Kafka outside K8s using NodePort, Load balancer, Ingress and OpenShift Routes. Easily secured using TLS over TCP. The Kube-native management of Kafka can also manage Kafka topics, users, Kafka MirrorMaker and Kafka Connect using Custom Resources. Allows for using K8s processes and tooling to manage complete Kafka applications. 
        - Kafka operators to deploy and configure an Apache Kafka cluster on K8s. 
        - Kafka Bridge provides a RESTful interface for your HTTP clients.
    - [NATS](https://nats.io/) : A lightweight, high-performance messaging system designed for microservices, IoT, and cloud-native systems. It supports various messaging models including pub-sub, request-reply, and queueing. NATS is known for its simplicity and performance.
    - [Redpanda](https://docs.redpanda.com/current/home/) : A newer, __Kafka-compatible streaming platform__ designed to offer better performance and easier operation. It is API-compatible with Kafka, which means existing Kafka clients and ecosystem tools work with Redpanda without modification. Redpanda is designed to be simpler to deploy and manage, with a focus on reducing operational overhead.
        - >Enabling SELinux can result in latency issues. If you wish to avoid such latency issues, do not use this mechanism.
- __Networking__
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
        - [Traefik](https://traefik.io/traefik/) : Automatically wires routes per Service discovery
        - [Ingress-Nginx](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/)
        - [Cilium](https://cilium.io/) : eBPF
        - Consul
    - [K8s Gateway API](https://gateway-api.sigs.k8s.io/implementations/#gateways)
        - [Traefik](https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/)
    - Service Mesh
        - [Istio](https://istio.io/)
            - [Envoy](https://www.envoyproxy.io/) Service Proxy (Sidecar)
        - Traefik : Automatically wires routes per Service discovery
        - [Linkerd](https://linkerd.io/) : Service Mesh (East-West) : mTLS + Load Balancing between services  
            - Sidecar Proxy (written in Rust).
        - Kuma
        - Consul
    - Service Discovery
        - etcd : K8s cluster
        - Consul : Multi-cluster
- __IA__/__Security__
    - [__AuthN__/__AuthZ__](https://kubernetes.io/docs/concepts/security/controlling-access/ "Kubernetes.io")
        - [__AuthN__](https://kubernetes.io/docs/reference/access-authn-authz/authentication/ "Kubernetes.io") (Authentication)
            - __K8s__ 
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
                            - Token (JWTs) generated by an OIDC provider, e.g., __Dex__ or [__Keycloak__](file:///D:/1%20Data/IT/Container/Kubernetes/K8s-AD-integration-Keycloak.html "K8s-AD-integration-Keycloak"), which may proxy an upstream Identity Provider (__IdP__) such as AD. K8s [recognizes the subject](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"), e.g., by token claims of user/group, or  `ServiceAccount` having K8s `cluster.user`. 
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
        - [__AuthZ__](https://kubernetes.io/docs/reference/access-authn-authz/authorization/ "Kubernetes.io") (Authorization) | Modules/[Modes](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules "Kubernetes.io")   
        Regardless of authentication method, 
        K8s can implement Role-based Access Control ([RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/ "Kubernetes.io")) model 
        against subjects ([known by request attribute(s)](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"))
        using a pair of K8s objects for each of the two scopes of K8s API resources (`api-resources`):
            - __K8s__
                1. Namespaced (`Deployment`, `Pod`, `Service`, &hellip;)
                    - `Role` : Rules declaring the allowed actions (`verbs`) upon `resources` scoped to APIs (`apiGroup`).
                    - `RoleBinding` : Binding a subject (authenticated user or ServiceAccount) to a role.
                1. Cluster-wide (`PersistentVolume`, `StorageClass`, &hellip;)
                    - `ClusterRole`
                    - `ClusterRoleBinding`
    - __Distributed-Workload Identities__ : AuthN providing IDs having AuthZ primitives.
        - [SPIFFE/SPIRE](https://spiffe.io/) : Successor to RBAC for __defining__ (SPIFFE) and __implementing__ (SPIRE) a __workload identity platform__ and access controls rooted in __Zero Trust__ (versus Perimeter Security) principles to mitigate attack risk. SPIFFE/SPIRE provides a __uniform identity layer across distributed systems__. The core idea is to issue   __SVIDs__ (SPIFFE Verifiable Identity Documents), of either __X.509__ or __JWT__, to workloads based on strong attestation (e.g., node identity, container metadata). __Tools__ like OPA, Istio, Linkerd, or Envoy with RBAC __consume SPIFFE IDs__ for authorization policies (__AuthZ__). So the same artifact (SVID) is used for both AuthN (proof of identity) and as _a handle for_ AuthZ rules.
            - __Secure Production Identity Framework for Everyone__ (SPIFFE) : An OSS framework specificition to provide __attested, cryptographic identities__ to distributed workloads; capable of bootstrapping and issuing identity to services; defines short-lived cryptographic identity documents (__SVID__) via a simple API. Workloads use these SVIDs when authenticating to other workloads, for example by establishing a TLS connection or by signing and verifying a JWT token.
            - __SPIFFE Runtime Environment__ ([SPIRE](https://spiffe.io/docs/latest/spire-about/spire-concepts/)) : a production-ready implementation of the SPIFFE APIs (pluggable multi-factor attestation and SPIFFE federation) that performs __node and workload attestation__ in order to securely issue SVIDs to workloads, and verify the SVIDs of other workloads, based on a predefined set of conditions.
                - `spiffe://cluster/ns/foo/sa/bar`
                    - A cryptographically verifiable identity
    - __Threat Detection__ / __Remediation__ : __CVE__s (Common Vulnerabilities and Exposures)
        - [K8s Adminssion Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
        - [Trivy](https://aquasecurity.github.io/trivy/v0.56/ "aquasecurity.github.io") : Scan OCI-container images, OS folders, Kubernetes clusters, Git repos, virtual machines, and more. And can create SBOM and CVE-vulnerabilities audits of them.
            - [`trivy-operator`](https://aquasecurity.github.io/trivy-operator/latest/ "aquasecurity.github.io") by Helm chart : Recurringly scan all container images : Generates `VulnerabilityReport`s per Pod, DaemonSet, &hellip; across all/declared Namespaces.
        - [Kubescape](https://kubescape.io/) (10K) : Runtime Detection 
        - [Falco](https://falco.org) by [Sysdig](https://sysdig.com/opensource/) (7K) : Threat detection/reporting : Runtime security across hosts, containers, Kubernetes, and cloud environments. It leverages custom rules on Linux kernel events and other data sources through plugins, enriching event data with contextual metadata to deliver real-time alerts. Falco enables the detection of abnormal behavior, potential security threats, and compliance violations.
        - [`cve-bin-tool`](https://pypi.org/project/cve-bin-tool/#finding-known-vulnerabilities-using-the-binary-scanner "PyPI.org") :  
            Python tool for finding known vulnerabilities in software, using data from the  <dfn title="National Vulnerability Database">NVD</dfn>'s list of  <dfn title="Common Vulnerabilities and Exposures">CVE</dfn>s as well as known vulnerability data from Redhat, Open Source Vulnerability Database (OSV), Gitlab Advisory Database (GAD), and Curl
    - __Policy Enforcement__ 
        - [K8s Adminssion Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
        - [Kyverno](https://kyverno.io) Policy as Code (6K) : 
            For example, [add a custom CA (CM volume/mount) to (labeled) Pods per Kyverno Policy](https://kyverno.io/policies/other/add-certificates-volume/add-certificates-volume/ "kyverno.io/policies").
            - [Kyverno CLI](https://kyverno.io/docs/kyverno-cli/) can be used to apply and test policies __off-cluster__ e.g., as part of an IaC and CI/CD pipelines.
            - [Kyverno Policy Reporter](https://kyverno.io/docs/kyverno-policy-reporter/) : a sub-project of Kyverno that provides in-cluster management of policy reports with a web-based graphical user interface.
            - [Kyverno JSON](https://kyverno.io/docs/kyverno-json/) : a sub-project of Kyverno that allows applying Kyverno policies to __off-cluster__ workload. It works on any JSON payload.
            - [Kyverno Chainsaw](https://kyverno.io/docs/kyverno-chainsaw/) sub-project of Kyverno provides declarative end-to-end testing for Kubernetes controllers.
        - [OPA/Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/)  (3.7K): Automated policy enforcement 
        - [Kubearmor](https://kubearmor.io)  (1.6K): Runtime Security Enforcement : Policy-based controls : a runtime Kubernetes security engine that uses eBPF and Linux Security Modules (LSM) for fortifying workloads based on Cloud Containers, IoT/Edge, and 5G networks.
    - __Secrets__
        - [__Hashicorp Vault__](https://github.com/hashicorp/vault) : [__OpenBao__](https://openbao.org/) (OSS fork)
            - [Implementations](https://chatgpt.com/share/67019858-ac38-8009-90f3-e824f420bf79 "ChatGPT"):
                - [`vault-helm`](https://github.com/hashicorp/vault-helm "GitHub")
                - [`vault-secrets-operator`](https://github.com/hashicorp/vault-secrets-operator "GitHub")
                - Vault Agent Sidecar Injection : Most secure (rest/transit) : 
              Transparent encrypt/decrypt of K8s `Secret` objects (`data`)
                - Vault CSI Driver :  Fetch secrets on container init and mount as files in the container.
                - External Secrets Operator : Integrates with external secret stores (Vault, AWS Secrets Manager, Google Cloud Secret Manager); syncs secrets from Vault into K8s `Secret` objects.
                - Direct API Calls to Vault : Configured per app.
        - [External Secrets Operator](https://external-secrets.io/latest/) : 
          Pull/Push secrets; sync K8s `Secret` objects (decrypted) with external store (encrypted).
        - [Teller](https://github.com/tellerops/teller) : Like External Secretes Operator; local CLI secrets manager for developers.
        - [Bitnami `SealedSecret`s](https://github.com/bitnami-labs/sealed-secrets) : 
            - Asymmetric crypto allows developers to encrypt secrets as "`SealedSecret`" K8s object (CRD) __to store outside the cluster__ in (public) Git repo or other untrusted environment. 
            - Automatically decrypts it and creates a regular Kubernetes Secret object, accessible to your applications. 
            - Once in the cluster, it is __stored unencrypted in K8s__ `Secret` object.
            - Components
                - A cluster-side `controller` / operator
                - A client-side utility: `kubeseal` : Utility encrypts secrets that only the controller can decrypt.
            - Transit Engine : works entirely within Vault and does not require a sidecar or agent within your Pods. It is used by the K8s control plane (e.g., API server) to perform encryption operations, ensuring data is encrypted when stored (e.g., in etcd) and decrypted when needed.
        - [SOPS](https://github.com/getsops/sops) (Secrets OPerationS) : 
          Secrets management; editor that interfaces with Vault etal.
        - [`age`](https://github.com/FiloSottile/age "GitHub : FiloSottile/age") (Actually Good Encryption) : A simple CLI providing AEAD encrypt/decrypt. 
          Rejoice over a replacement for the obnoxiously complicated PGP (Pretty Good Privacy) project. 
            ```bash
            # Install : bad binary
            sudo curl -sSLo /usr/local/bin/age https://dl.filippo.io/age/latest?for=linux/amd64
            # Install : okay
            go install filippo.io/age/cmd/...@latest
            sudo ln -s /home/u1/go/bin/age /usr/local/bin
            
            # Generate public-private key pair
            key=age.key
            pub="$(age-keygen -o $key 2>&1 |cut -d':' -f2 )"
            # Encrypt a source (archive)
            tar cvz ~/$src |age -r $pub > $src.tgz.age
            # Decrypt a source
            age -d -i $key $src.tgz.age > $src.tgz
            ```
    - __Signing__
        - Sigstore Cosign
        - Notary
    - __TLS__ : [Automated TLS Management (Enterprise Grade)](https://chatgpt.com/share/6897a869-d390-8009-b873-da33b20e8e0b "ChatGPT 5")
        - __cert-manager__ ([cert-manager.io](https://cert-manager.io/ "cert-manager.io")|[GitHub](https://github.com/cert-manager)): _&hellip;obtain certificates from &hellip; public &hellip; as well as private Issuers &hellip;, and ensure the certificates are valid and up-to-date, and &hellip; renew certificates at a configured time before expiry._
            - Private Issuers (Backends):
                - Smallstep [__`step-ca`__](https://smallstep.com/docs/step-ca/ "smallstep.com")  
                An online CA for secure, automated X.509 and SSH certificate management. It's the server counterpart to `step` CLI. Run step-ca (internal ACME) + `step-issuer` or use `cert-manager`’s ACME issuer pointed at `step-ca`. Provides air-gapped ACME + tight Kubernetes integration.
                    - Generate TLS certificates for private infrastructure using the ACME protocol.
                    - Automate TLS certificate renewal.
                    - Add Automated Certificate Management Environment (ACME) support to a legacy subordinate CA.
                    - Issue short-lived SSH certificates via OAuth OIDC single sign on.
                    - Issue customized X.509 and SSH certificates.
                - __Hashicorp Vault PKI__ | [__OpenBao PKI__](https://openbao.org/docs/secrets/pki/)
                - __Venafi TLS Protect for Kubernetes__ (the commercial successor to __Jetstack__ Secure): central policy/visibility across clusters and CAs (public or private). If you want enterprise governance and inventory at scale, this is the “batteries-included” option.
- __Storage__
    - [__MinIO__](file:///D:/1%20Data/IT/Container/Kubernetes/Storage/MinIO/MinIO.html "MinIO.html") : a Kubernetes-native high performance object store with an __S3-compatible API__; 
      supports deploying MinIO Tenants onto private and public cloud infrastructures AKA Hybrid Cloud.
        - __MinIO Operator__ : [`minio/operator`](https://github.com/minio/operator/ "GitHub") | [Docs](https://min.io/docs/minio/kubernetes/upstream/operations/installation.html#minio-operator-installation "min.io/docs")
    - [__Rook__](https://rook.github.io/docs/rook/latest-release/Getting-Started/intro/) : Open source cloud-native storage orchestrator, providing the platform, 
      framework, and support for __Ceph__ storage to natively integrate with cloud-native environments. Provides __S3__/Swift API.
        - [__Ceph__](https://ceph.com/en/) : Distributed storage system that provides __file__, __block__ and __object__ storage and is deployed in large scale production clusters on commodity hardware.
    - JuiceFS : Distributed POSIX file system built on top of Redis and S3 (MinIO).
    - Gluster
    - Longhorn 
    - KubeFS
    - __Database__
        - Managed
            - Aiven 
        - KubeBlocks : K8s Operator : Supports many databases
        - [TiKV](https://github.com/tikv/tikv) : distributed, and transactional key-value database. FOSS. CNCF Graduated project.
        - [Cassandra](https://github.com/apache/cassandra) : NoSQL distributed database. Apache/CNCF project.
        - [NiFi](https://github.com/apache/nifi) @ [GPTchat](https://chatgpt.com/share/0935e21e-30dd-445b-97b3-1d8ed46782ce) : A system to ingest, process and distribute data (from anywhere); automated and managed flow of information between systems; suited for complex data integration, ETL processes, real-time data flows, and scenarios requiring detailed data lineage and tracking. Apache/CNCF project.
        - [CloudNativePG](https://cloudnative-pg.io/) (CNPG) : K8s Operator covering full lifecycle of a highly available PostgreSQL database cluster with a __primary/standby architecture__, using native __streaming replication__. A CNCF project.
        - Atlas Operator : Schema
- __Misc__
    - Charm : Library and Tools
    - Velero : Backup K8s cluster and `PersistentVolume`s

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

## Schemes for Unique Identifier

- [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) (Universally Unique Identifier):  
  A widely used 128-bit number that guarantees uniqueness across different systems, often used in databases and distributed systems; considered the standard for generating unique identifiers. [1, 2, 3]  
- NanoID:   
A compact, URL-friendly unique string generator with a similar collision probability to UUID, designed for JavaScript environments [1, 4, 5]  
- ULID (Universally Unique Lexicographically Sortable Identifier): A unique identifier that is also sortable, combining timestamp and randomness for efficient database indexing [1, 6]  
- CUID (Collision-resistant Unique Identifier): A unique identifier that incorporates a timestamp, counter, and random characters, designed for collision resistance in distributed systems [1, 5]  
- Snowflake ID: A unique identifier scheme often used in distributed databases, incorporating timestamps and sequence numbers to generate unique IDs [6, 7]  

### Key points to consider when choosing a unique identifier scheme: 

- __Collision probability__: How likely is it for two different identifiers to be the same. 
- Length and __readability__: How long is the identifier and __how easy is it to read__ and interpret. 
- __Sorting capabilities__: Whether the identifier can be __easily sorted in a database__ 
- Generation method: How the identifier is generated, __whether it uses randomness or timestamps__ 


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
