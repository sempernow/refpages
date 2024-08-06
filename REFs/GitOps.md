# [GitOps](https://opengitops.dev/ "OpenGitOps.dev") `v1.0.0`

>GitOps is **an operational framework** that takes DevOps best practices used for application development such as version control, collaboration, compliance, and CI/CD, and applies them to infrastructure automation. GitOps consists of infrastructure as code (IaC), configuration management (CM), <def title="Provide everything below the microservices">platform engineering</def>, and continuous integration and continuous delivery (CI/CD).

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

1. **Declarative**  
    A system managed by GitOps must have its desired state expressed declaratively.
2. **Versioned and Immutable**  
    Desired state is stored in a way that enforces immutability, versioning and retains a complete version history.
3. **Pulled Automatically**  
    Software agents automatically pull the desired state declarations from the source.
4. **Continuously Reconciled**  
    Software agents continuously observe actual system state and attempt to apply the desired state.

## Results

- A standard workflow for application development.
- Increased security for setting application requirements upfront.
- Improved reliability with visibility and version control through Git.
- Consistency across clusters and their environments.

## Tools | [CNCF Landscape](https://landscape.cncf.io/)

 [DevOps Toolkit](https://www.youtube.com/watch?v=tgwxMfIsLJY "YouTube")

- **Service Catalog** : UI of IDP : built/maintained 
  by GitOps/DevOps vendor/admin, not by end users.
    - Port : SasS only
    - [Backstage.io](https://backstage.io/) : Build Developers' Portals (IDP)
    - [Crossplane.io](https://www.crossplane.io/ "crossplane.io") @ [GitHub](https://github.com/crossplane)  
        - Programmable Control Plane, Controllers, APIs
        - Embed IaC tooling such as Terraform, Helm, Ansible,
          which converts IaC to Cloud-vendors' API requests.
- **IaC** : **Service Management** : Provision/Configure:  
    - [**Kubernetes**](https://kubernetes.io/docs/home/ "Kubernetes.io") : 
      Cluster API, Crossplane, &hellip;  
      K8s is a **universal Control Plane**
    - [**Terraform**](https://registry.terraform.io):  
        Declarative provisioning of cloud infrastructure 
        and policies (per-vendor modules), 
        and managing Kubernetes resources.
    - [**Ansible**](https://docs.ansible.com/ansible/latest/index.html):  
        Provision and configure infrastructure, OS/packages, 
        and application software in any environment.
        A comprehensive, versatile automation tool 
        allowing for both declarative and imperative methods.
    - Pulumi : IaC in any language
- **IaC** : **Workloads**
    - Application Management (K8s Manifests)
        - [**Timoni.sh**](timoni.sh) (Uses CUE)  
          Distribution and Lifecycle Management for Cloud-Native Applictions
        - [**Helm**](https://helm.sh/docs/helm/helm/ "helm.sh/docs/"):  
            A package manager for Kubernetes, Helm can be used to package applications into charts, 
            which are then version-controlled in Git repositories. Helm charts can be deployed using GitOps tools like Flux or Argo CD.
        - [**Kustomize**](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/ "Kubernetes.io/docs/"):  
            Generate, customize, and/or otherwise manage Kubernetes objects using files (YAML) stored in a Git repo. 
            It's integrated into `kubectl` and can be used with other GitOps tools to manage deployments. 
            Use to modify Helm chart per environment.
        - [KCL](https://www.kcl-lang.io/ "kcl-lang.io") @ [GitHub](https://github.com/kcl-lang/kcl/)
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
        - [**Flux**](https://github.com/fluxcd/flux2)  
            A tool to automatically sync Kubernetes clusters/applications
            with their configuration sources, across their lifecycles.
        - [**Argo CD**](https://github.com/argoproj/argo-cd):   
            Visualize (Web UI) and manage the lifecycle of Kubernetes applications;
            supports automated or manual syncing of changes.
            - Argo Workflows + Argo Events required = CD 
                - Argo Events > Tekton Events
- __Logging__ (Cluster-level) AKA **Log Aggregation** : 
  So that logs survive their (ephemeral) generator, be that in a Node, Pod, or container.
    - **Elastic stack** : [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html "Elastic.co") (TSDB backend) / [Kibana](https://www.elastic.co/guide/en/kibana/current/introduction.html "Elastic.co") (Web UI frontend) : 
       to collect, store, query, and visualize log data;
        - [ECK (Elastic Cloud on K8s) Operator](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html "Elastic.co") 
            - Requires a **collector**/**forwarder** AKA *The Workhorse*; a data processing pipeline that ingests data from sources, transforms (normalizes) it, and then forwards it, i.e., **Unified Loggging** : 
                - [Logstash](https://www.elastic.co/logstash "Elastic.co") : Elastic's native solution
                - [Fluentd](https://www.fluentd.org/architecture "Fluentd.org")
                    - [Fluent Bit](https://fluentbit.io/) : 
                    *Lightweight forwarder for Fluentd*.
                    - [Fluent Operator](https://github.com/fluent/fluent-operator "GitHub") : 
                      Manage **Fluent Bit** and **Fluentd** the Kubernetes way. 
                      (Was FluentBit Operator)
    - [Grafana Loki](https://grafana.com/oss/loki/) | [`grafana/loki`](https://github.com/grafana/loki/ "GitHub") ([Install](https://grafana.com/docs/loki/latest/setup/install/)) : "*Prometheus, but for logs*". A lightweight alternative to Elastic stack.
        - **Does not provide full-text indexing** of logs; indexes only the logs' metadata (**labels**).
        - No viable installation method is available (2024-08), contrary to project claims. 
- **Observability** : Distributed **Tracing** and **Metrics**
    - [Prometheus](https://prometheus.io/ "Prometheus.io") : TSDB and monitoring system optimized for telemetry (metrics and tracing). 
    Does not scale, and has horrible alerts (Alertmanager). Provision using [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator-1) :
        - [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#prometheus-operator "GitHub") :   
        The bare operator ([`bundle.yaml`](https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml "GitHub"))
        - **`kube-prometheus`** : *A collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide &hellip; **end-to-end Kubernetes cluster monitoring** with Prometheus using the Prometheus Operator.* 
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
    - [Jaeger](https://www.jaegertracing.io/docs/1.18/opentelemetry/ "JaegerTracing.io") : Tracing collector that integrates with OpenTelemetry
        - [Jaeger Operator](https://www.jaegertracing.io/docs/1.60/operator/ "JaegerTracing.io") @ [GitHub](https://github.com/jaegertracing/jaeger-operator "GitHub")
            - Requires [`cert-manager`](https://cert-manager.io/docs/)
    - [OpenTelemetry](https://opentelemetry.io/docs/collector/) (OTEL)
      Vendor-agnostic tracing library; 
      app library (almost all languages covered) for generating traces
        - [OpenTelemetry Operator](https://opentelemetry.io/docs/kubernetes/operator/ "OpenTelemetry.io") @ [GitHub](https://github.com/open-telemetry/opentelemetry-operator "GitHub") : 
        K8s Operator to manage collectors ([OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector "GitHub")) and auto-instrumentation of workloads using OTEL libraries. 
    - [Grafana](https://grafana.com/) : Web UI : Dashboards
        - [Grafana Tempo](https://github.com/grafana/tempo) : Tracing backend; scales and integrates with Jaeger, Zipkin, and OpenTelemetry; fixes Jaeger shortcommings
    - [VictoriaMetrics](https://victoriametrics.com/products/open-source/) : 
      TSDB & Monitoring Solution (as a Service); 
      compatible with Prometheus
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
- **Database**
    - Managed
        - Aiven 
    - KubeBlocks : K8s Operator : Supports many databases
    - CNPG : Cloud-native PG
    - Atlas Operator : Schema
- **Security**
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
- **Netowrking** 
    - Cilium 
    - K8s Gateway API 
    - Istio 
    - Linkerd
    - Kuma
- **Misc**
    - Charm : Library and Tools

## Methods

- **Declarative Configuration**:  
    Use declarative configurations (YAML files) for all resources and store them in a Git repository. 
    This approach ensures that the desired state of your cluster is version-controlled and auditable.
    - **Branching Strategies**:  
        [Trunk-based](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development) 
        rather than [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) 
        to manage different environments (development, staging, production) or to handle feature development and releases.
- **Pull Request Workflow**:  
    Use pull (merge) requests (PR/MR) to manage changes to the Kubernetes configuration. 
    This allows for code review, approval processes, 
    and automated testing before changes are merged and applied.
- **Automated Deployment**:  
    Implement CI/CD pipelines that automatically apply changes from Git to your Kubernetes cluster. 
    This could involve testing changes in a staging environment before promoting them to production.
- **Disaster Recovery**:  
    Regularly back up your Git repository and Kubernetes cluster state. 
    Ensure you have a process in place for restoring from backups in case of a disaster.
    
## Configuration 

- **Repository Structure**:  
    Organize your Git repository in a way that reflects your deployment environments and application structure. 
    This could involve separate directories for each environment and application.
- **Secrets Management**:  
    Use tools like [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), 
    [SOPS](https://github.com/getsops/sops), 
    or [Vault](https://github.com/hashicorp/vault) for encrypting secrets that are stored in Git. 
    This ensures that sensitive information is securely managed.
- **Monitoring and Alerting**:  
    Integrate monitoring and alerting tools to track the health of your deployments and the Kubernetes cluster. 
    [Prometheus](https://prometheus.io/docs/introduction/overview/) and [Grafana](https://grafana.com/) 
    are commonly used tools that can be managed via GitOps.
- **Policy Enforcement**:  
    Use policy-as-code tools like Open Policy Agent (OPA) or [Kyverno](https://github.com/kyverno/kyverno) 
    to enforce policies on your Kubernetes clusters. 
    Store policies in Git to apply them consistently across your environments.
- **Security Scanning**:  
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

