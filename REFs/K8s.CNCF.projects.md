# [LINK](https://# "___")

# Ephemeral Storage 

The `kubelet` tracks: 

- `emptyDir` volumes, except volumes of `tmpfs`
- Directories holding node-level logs
- Writeable container layers

>The `kubelet` tracks ***only the root filesystem*** for ephemeral storage. OS layouts that mount a separate disk to `/var/lib/kubelet` or `/var/lib/containers` *will not report ephemeral storage correctly*.

# Cluster-level Logging 

Aggregate application logs and store externally so they survive the pod.

## EFK stack | [HowTo](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes "DigitalOcean.com") | [Helm](https://artifacthub.io/packages/helm/elastic/elasticsearch)

- Elasticsearch: This is a highly scalable search and analytics engine. It allows you to store, search, and analyze big volumes of data quickly and in near real-time. In the context of Kubernetes, it is used as the central storage for logs.
- Fluentd: Fluentd is an open-source data collector for unified logging. It is used to collect and send logs from different sources (in this case, the Kubernetes nodes and pods) to Elasticsearch. Fluentd is efficient and flexible, with a lightweight footprint and a pluggable architecture.
- Kibana: Kibana is a visualization layer that works on top of Elasticsearch. It provides a user interface for visualizing and querying the log data stored in Elasticsearch. This makes it easier to perform data analysis, monitor applications, and troubleshoot issues.

## ELK stack 

Logstash instead of Fluentd for log processing and aggregation. Logstash is more resource-intensive but offers more complex processing capabilities.

## Loki/Grafana

Newer. Simplest.

# GitOps : CNCF Projects

Argo CD and Flux CD (Flux) are both popular open-source tools used for GitOps in Kubernetes environments. They enable **automated, continuous delivery** (CD) and make it easier to manage deployments and operations **using Git as the source of truth**. Flagger, on the other hand, is a progressive delivery tool often used in conjunction with Flux for implementing advanced deployment strategies like canary releases and A/B testing.

## Argo CD

- Purpose: Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes, like Flux.
- Key Features:
    - Application Definitions, Configurations, and Environments: All these are declaratively managed and versioned in Git.
    - Automated Deployment: Argo CD automatically applies changes made in the Git repository to the designated Kubernetes clusters.
    - Visualizations and UI: Argo CD provides a rich UI and CLI for viewing the state and history of applications, aiding in troubleshooting and management.
    - Rollbacks and Manual Syncs: Supports rollbacks and manual interventions for syncing with Git repositories.

## Argo Rollouts
    
Similar to Flagger. It offers advanced deployment strategies like canary and blue/green.


## Flux CD (Flux) and Flagger

- Flux CD (Flux):
    - Purpose: Flux is primarily a continuous delivery solution that synchronizes a Git repository with a Kubernetes cluster. It ensures that the state of the cluster matches the configuration stored in the Git repository.
    - Key Features: Flux supports automated deployments, where changes to the Git repo trigger updates in the Kubernetes cluster. It also has capabilities for handling secret management and multi-tenancy.
    - Integration with Flagger: Flux can be used together with Flagger for progressive delivery. Flagger extends Flux’s functionality by adding advanced deployment strategies.
- Flagger:
    - Purpose: Flagger is designed for **progressive delivery** techniques like canary releases, A/B testing, and blue/green deployments.
    - Key Features: It automates the release process by gradually shifting traffic to the new version while measuring metrics and running conformance tests. If anomalies are detected, Flagger can automatically rollback.
    - Integration with Service Meshes: Flagger is often used with service meshes like Istio, Linkerd, and others, leveraging their features for traffic shifting and monitoring.



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

