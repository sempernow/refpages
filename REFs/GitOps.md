# [GitOps](https://opengitops.dev/ "OpenGitOps.dev") `v1.0.0`

>GitOps is __an operational framework__ that takes DevOps best practices used for application development such as version control, collaboration, compliance, and CI/CD, and applies them to infrastructure automation. GitOps consists of infrastructure as code (IaC), configuration management (CM), <def title="Provide everything below the microservices">platform engineering</def>, and continuous integration and continuous delivery (CI/CD).

## GitOps v. DevOps

GitOps is considered a branch or category of DevOps.
Both are methodoligies of software development, delivery, 
and lifecycle management.  

GitOps focuses on infrastructure for containerized workloads
across environments, especially when run on Kubernetes 
and typically in the cloud. 

DevOps has a braoder scope, 
from the application-developers' environment
to all matters of deployment automation 
across environments.

DevOps is about automation across the lifecycle of an application.
GitOps extends that with disciplined methods across all layers of all components, 
from infra to services, with the goal of repeatable, verifiable deployment states.

## Principles

1. __Declarative__  
    A system managed by GitOps must have its desired state expressed declaratively.
2. __Versioned and Immutable__  
    Desired state is stored in a way that enforces immutability, versioning and retains a complete version history.
3. __Pulled Automatically__  
    Software agents automatically pull the desired state declarations from the source.
4. __Continuously Reconciled__  
    Software agents continuously observe actual system state and attempt to apply the desired state.

## Results

- A standard workflow for application development.
- Increased security for setting application requirements upfront.
- Improved reliability with visibility and version control through Git.
- Consistency across clusters and their environments.

## Tools | [CNCF Landscape](https://landscape.cncf.io/)

 [DevOps Toolkit](https://www.youtube.com/watch?v=tgwxMfIsLJY "YouTube")

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
    - [__Authentication__](https://kubernetes.io/docs/reference/access-authn-authz/authentication/ "Kubernetes.io") (Authn)
        - [Authentication Plugins](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authentication-strategies "Kubernetes.io")
            - Static Token file
                - Bearer token
                - Service Account token
            - X.509 certificates
            - [Open ID Connect (OIDC) token](https://kubernetes.io/docs/reference/access-authn-authz/rbac/ "Kubernetes.io")
            - Authentication proxy
            - Webhook
        - Two scenarios
            1. Clients authenticating against the K8s API server
                - The two most common methods:
                    - [X.509 certificate issued by K8s CA](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user "Kubernetes.io") 
                    - Token (JWTs) generated by an OIDC provider, e.g., __Dex__ or __Keycloak__, that acts as proxy of upstream Identity Provider (__IdP__), such as AD/LDAP, against which it authenticates a subject, which is [presumably recognizable to K8s](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"), i.e., a user/group or `ServiceAccount` having K8s `cluster.user` and (`Cluster`)`RoleBinding`. 
            1. Users authenticating at web UI against an application running on the cluster.
                - Token (JWTs) generated by an OIDC provider (same as above method). 
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
- __Logging__ (Cluster-level) AKA __Log Aggregation__ : 
  So that logs survive their (ephemeral) generator, be that of a host or container process, or K8s Node, Pod, &hellip; .
    - __Elastic stack__ : to collect, store, query, and visualize log data. Composed of [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html "Elastic.co") (backend; distributed search &amp; analytics engine based on [Lucene](https://en.wikipedia.org/wiki/Apache_Lucene "Wikipedia")) &amp; [Kibana](https://www.elastic.co/guide/en/kibana/current/introduction.html "Elastic.co") (frontend; Web UI) 
        - [ECK (Elastic Cloud on K8s) Operator](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html "Elastic.co")  @ [Air-gap environment](https://chatgpt.com/share/5e27759e-6741-4c72-aed6-1458f3562eba "ChatGPT.com")
            - __Requires__ a __collector__/__forwarder__; a data processing pipeline to ingest data from sources, then transform (normalize) and forward that data. This is the stack's *workhorse*. It provides __Unified Loggging__ : 
                - [Logstash](https://www.elastic.co/logstash "Elastic.co") : Elastic's native solution
                - [Fluentd](https://www.fluentd.org/architecture "Fluentd.org") : Data collector (not limited to logs, metrics and tracing).
                    - [Fluent Bit](https://fluentbit.io/) : 
                    *Lightweight forwarder for Fluentd*.
                    - [Fluent Operator](https://github.com/fluent/fluent-operator "GitHub"), formerly "FluentBit Operator" : 
                      *Manage Fluent Bit and Fluentd the Kubernetes way*.
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
        - cert-manager
- __Netowrking__ 
    - Cilium 
    - K8s Gateway API 
    - Istio 
    - Linkerd
    - Kuma
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

