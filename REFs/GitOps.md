# [GitOps](https://opengitops.dev/ "OpenGitOps.dev") `v1.0.0`

>GitOps is an operational framework that takes DevOps best practices used for application development such as version control, collaboration, compliance, and CI/CD, and applies them to infrastructure automation. GitOps consists of infrastructure as code (IaC), configuration management (CM), <def title="Provide everything below the microservices">platform engineering</def>, and continuous integration and continuous delivery (CI/CD).

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

- Infrastructure : Provision/Configure:  
    - [**Terraform**](https://registry.terraform.io):  
        Declarative provisioning of cloud infrastructure 
        and policies (per-vendor modules), 
        and managing Kubernetes resources.
    - [**Ansible**](https://docs.ansible.com/ansible/latest/index.html):  
        Provision and configure infrastructure, OS/packages, 
        and application software in any environment.
        A comprehensive, versatile automation tool 
        allowing for both declarative and imperative methods.
- Workloads : 
    - Install Applications :  
      Helm *and* Kustomize
        - [**Helm**](https://helm.sh/docs/helm/helm/ "helm.sh/docs/"):  
            A package manager for Kubernetes, Helm can be used to package applications into charts, 
            which are then version-controlled in Git repositories. Helm charts can be deployed using GitOps tools like Flux or Argo CD.
        - [**Kustomize**](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/ "Kubernetes.io/docs/"):  
            Generate, customize, and/or otherwise manage Kubernetes objects using files (YAML) stored in a Git repo. 
            It's integrated into `kubectl` and can be used with other GitOps tools to manage deployments. 
            Use to modify Helm chart per environment.
    - Manage Application Lifecycle :  
    Flux *or* Argo CD
        - [**Flux**](https://github.com/fluxcd/flux2)  
            A tool to automatically sync Kubernetes clusters/applications
            with their configuration sources, across their lifecycles.
        - [**Argo CD**](https://github.com/argoproj/argo-cd):   
            Visualize (Web UI) and manage the lifecycle of Kubernetes applications;
            supports automated or manual syncing of changes.

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

