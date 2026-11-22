# [GitLab Runner](https://docs.gitlab.com/runner/) | [Operator](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator "gitlab.com")


## Q: 

How to configure custom `cache_dir` of `gitlab-runner` if it's a kubernetes executor

## A:

Here's the **complete, consolidated configuration** to properly set up a custom cache directory with correct permissions in your GitLab Kubernetes runner:

### 1. Final `config.toml` Configuration
```toml
[[runners]]
  name = "kubernetes-runner"
  url = "https://gitlab.example.com"
  token = "YOUR_RUNNER_TOKEN"
  executor = "kubernetes"
  cache_dir = "/mnt/cache"  # Your custom cache path
  
  # Critical permission settings
  [runners.kubernetes.pod_security_context]
    fs_group = 1000         # Ensures write permission for gitlab-runner
    run_as_user = 1000      # Default gitlab-runner user
    run_as_group = 1000     # Default gitlab-runner group
  
  # PVC Mount (replace with your existing PVC name)
  [runners.kubernetes]
    [[runners.kubernetes.volumes.pvc]]
      name = "gitlab-runner-cache"  # Must match your PVC name
      mount_path = "/mnt/cache"     # Must match cache_dir
```

### 2. Required Kubernetes Resources
```yaml
# PVC Definition (if not existing)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitlab-runner-cache  # ← Must match config.toml
spec:
  accessModes:
    - ReadWriteMany          # Critical for cache functionality
  resources:
    requests:
      storage: 10Gi         # Adjust size as needed
  storageClassName: standard # Match your storage class
```

### 3. Verification Checklist
1. **PVC Exists and is Bound**:
   ```bash
   kubectl get pvc gitlab-runner-cache
   ```
   Should show STATUS=Bound

2. **Correct Permissions**:
   ```bash
   kubectl exec -it <runner-pod> -- ls -ld /mnt/cache
   ```
   Should show:
   ```
   drwxrwsr-x 2 1000 1000 4096 ...
   ```
   (The 's' in group permissions indicates working setgid)

3. **Write Test**:
   ```bash
   kubectl exec -it <runner-pod> -- \
     sh -c "touch /mnt/cache/testfile && ls -l /mnt/cache/testfile"
   ```

### Key Takeaways
1. **Four Critical Elements**:
   - `cache_dir` in `[[runners]]`
   - Matching PVC `mount_path`
   - `pod_security_context` with `fs_group`
   - PVC with `ReadWriteMany` access

2. **Permission Flow**:
   ```mermaid
   graph TD
     A[PVC Storage] -->|inherits| B[PV Permissions]
     B -->|modified by| C[Pod fs_group]
     C -->|applied to| D[/mnt/cache]
     D -->|used by| E[GitLab Runner]
   ```

3. **Troubleshooting Tip**:
   If files still appear as root-owned, add this to your jobs:
   ```yaml
   variables:
     FF_KUBERNETES_HONOR_ENTRYPOINT: "1"  # Ensures pod user context is respected
   ```

## Q:

Regarding RBAC, if a GitLab runner is deployed into K8s cluster under its own namespace, and the CI/CD has `kubectl` that deploys app to cluster, what `Role`s must it have for pipelines to __deploy to any declared namespace__?

## A: 

To allow a GitLab Runner deployed into a Kubernetes cluster under its own namespace to deploy applications across multiple namespaces using `kubectl` in GitLab CI/CD pipelines, you'll need to set up appropriate RBAC (Role-Based Access Control) permissions. Here's a step-by-step guide on configuring these permissions:

### 1. Create a Service Account
First, create a Service Account in the GitLab Runner's namespace that the runner will use to interact with the Kubernetes API.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-runner
  namespace: gitlab-runner-namespace
```

### 2. Define ClusterRole
You need a `ClusterRole` that grants the permissions needed to deploy resources to any namespace. This role typically includes permissions for managing deployments, statefulsets, pods, services, configmaps, and other relevant resources across all namespaces.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: deployment-manager
rules:
- apiGroups: ["", "apps", "batch", "extensions", "networking.k8s.io"]
  resources: ["deployments", "replicasets", "pods", "services", "configmaps", "secrets", "persistentvolumeclaims", "ingresses", "jobs", "cronjobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "create", "update", "delete"]
```
- [Configure runner API permissions](https://docs.gitlab.com/runner/executors/kubernetes/#configure-runner-api-permissions)

### 3. Bind ClusterRole to Service Account
Create a `ClusterRoleBinding` that binds the `ClusterRole` to the Service Account created in step 1. This binding allows the GitLab Runner to manage resources in all namespaces.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-runner-deployment-manager
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: gitlab-runner-namespace
roleRef:
  kind: ClusterRole
  name: deployment-manager
  apiGroup: rbac.authorization.k8s.io
```

### 4. Configure GitLab CI/CD to Use the Service Account
Ensure your GitLab CI/CD pipelines are configured to use the created Service Account. This is usually done by setting the `serviceAccountName` in the pod template for the GitLab Runner’s jobs.

```yaml
serviceAccountName: gitlab-runner
```

### Additional Considerations
- **Security**: Providing broad permissions can pose security risks. Always adhere to the principle of least privilege by granting only the necessary permissions needed for the tasks.
- **Namespace Management**: If the deployments are sensitive or require strict separation, consider using more granular roles and bindings specific to each namespace rather than a single cluster-wide role.
- **Secrets Management**: Be cautious with permissions around secrets to prevent unauthorized access to sensitive information.

This setup assumes that you're managing deployments across various namespaces and need a wide range of Kubernetes resource access. Adjust the resources and verbs according to your specific CI/CD requirements.


## Q:

How to scope a runner to a group or project and register it, if its deployed on K8s and via Helm chart?

## A:

To scope a GitLab Runner to a specific group or project, you can __register the runner with that particular group or project__. This scoping __ensures that the runner only picks up jobs from the group or project it's associated with__, which can help manage resources and permissions effectively, especially in __environments with multiple teams or projects__. Here’s how you can do it:

### Registering a Runner to a Project

1. **Go to the Project’s Settings**:
   - Navigate to your project in GitLab.
   - Click on **Settings** > **CI/CD** and expand the **Runners** section.

2. **Specific Runners**:
   - In the **Runners** section, you’ll see a description of how to register a new runner specifically for this project. This includes a unique registration token for the project.

To scope a GitLab Runner installed via a Helm chart to a specific group or project, you need to register the runner with specific registration tokens from either the group or project level rather than using the instance-wide registration token. Here's how you can achieve this:

### Step 1: Obtain the Registration Token
First, you need to get the registration token from the GitLab group or project you want to scope the runner to:

- **For a Group:**
  1. Go to your group’s homepage on GitLab.
  2. Click on **Settings** > **CI/CD**.
  3. Expand the **Runners** section to find the registration token.

- **For a Project:**
  1. Go to your project’s homepage on GitLab.
  2. Click on **Settings** > **CI/CD**.
  3. Expand the **Runners** section to find the registration token.

### Step 2: Configure the Helm Values

Modify the `values.yaml` file used for deploying the GitLab Runner Helm chart to include this registration token. Ensure you also set the `runnerRegistrationToken` to the token you retrieved from the group or project:

```yaml
gitlabUrl: https://gitlab.example.com/
runnerRegistrationToken: "PROJECT_OR_GROUP_REGISTRATION_TOKEN"

## For runners scoped to a specific project or group
runners:
  ## Register the runner to the specific project or group
  tags: "group-specific,example"
  locked: true  # Set to 'true' to lock the runner to the current project/group

## Other configuration as required...
```

In this configuration:
- `gitlabUrl` should be set to your GitLab instance URL.
- `runnerRegistrationToken` is the token you obtained from your GitLab group or project settings.
- `tags` can be used to specify specific runner tags which help in assigning jobs to this runner.
- Setting `locked: true` ensures the runner is locked to the project or group (only available at the project level).

### Step 3: Install/Upgrade the Runner
If you are installing the runner for the first time, use the following command:

```bash
helm install my-runner-name gitlab/gitlab-runner -f values.yaml
```

If you already have a runner installed and need to reconfigure or update it:

```bash
helm upgrade my-runner-name gitlab/gitlab-runner -f values.yaml
```

This setup will register the runner with GitLab scoped to the specific project or group using the registration token from that level. By using the registration token from a specific group or project, the runner will automatically be associated and locked to that scope, assuming `locked` is set appropriately in the values.

### Additional Considerations
- **Namespace**: Make sure that the runner is installed in the appropriate Kubernetes namespace if you are using Kubernetes namespaces for logical separation between projects or environments.
- **Executor Type**: When registering the runner, choose an executor that matches your environment and needs (e.g., Docker for container-based builds, Kubernetes for clusters, etc.).
- **Tags**: Tags can be used to control job assignment further. Jobs can specify tags to determine which runner should pick them up.
- **Concurrent Jobs**: If your runner is expected to handle multiple jobs, configure its concurrency settings accordingly.
- **Security**: Be careful with the scope of permissions and access that your runner has, especially in shared environments. Ensure it only has access to necessary resources.

By scoping runners to specific projects or groups, you can better manage access, improve security, and optimize resource utilization in your CI/CD workflows.


## Q:

Is it advised to have a runner per namespace, and so Role and Rolebinding would suffice instead of Cluster equivalents.

## A: 

Yes, using a separate GitLab Runner per namespace with corresponding Role and RoleBinding, rather than a ClusterRole and ClusterRoleBinding, is often advised, especially when dealing with a multi-tenant Kubernetes environment or when you want to enforce strict isolation and security policies between different projects or teams. This approach aligns with the principle of least privilege, ensuring that the runner has only the necessary permissions within a specific namespace.

### Advantages of Using Role and RoleBinding Per Namespace

**1. Security and Isolation:** By restricting a runner to a specific namespace, you ensure that it can only access resources within that namespace. This prevents accidental or malicious access to resources in other parts of the cluster.

**2. Resource Management:** Runners scoped to a namespace can be better tailored in terms of the resources they use (CPU, memory limits, etc.), which can improve scheduling efficiency and resource allocation.

**3. Access Control:** It simplifies management of access controls, as you can directly apply policies relevant to the specific projects or teams using that namespace without affecting others.

**4. Organizational Clarity:** It helps in maintaining clarity in CI/CD processes where different teams or projects have specific configurations, secrets, or environment setups that are not shared across the organization.

### How to Set Up Role and RoleBinding for a GitLab Runner

You would typically proceed as follows to set up a GitLab Runner with a Role and RoleBinding scoped to a single namespace:

#### Create the Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-runner
  namespace: specific-namespace
```

#### Define the Role

This Role example gives permissions to manage pods and deployments within a specific namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: specific-namespace
  name: gitlab-runner-role
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "pods/exec", "pods/portforward", "deployments"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
```
- See next Q/A (below) for broader access settings
- [Configure runner API permissions](https://docs.gitlab.com/runner/executors/kubernetes/#configure-runner-api-permissions)

#### Create a RoleBinding

This binds the previously defined Role to the Service Account.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner-rolebinding
  namespace: specific-namespace
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: specific-namespace
roleRef:
  kind: Role
  name: gitlab-runner-role
  apiGroup: rbac.authorization.k8s.io
```

#### Configure GitLab Runner

Make sure your GitLab CI configuration uses the service account and that the runner is configured to operate within the intended namespace.

### Considerations

- **Scalability**: While this approach is more secure, it might require more management overhead as the number of namespaces and runners increases.
- **Complexity**: Each runner's configuration and maintenance could become more complex, especially in dynamic environments with many microservices or frequent changes.
- **Resource Utilization**: Multiple runners might lead to underutilization of resources unless carefully managed.

Implementing a GitLab Runner per namespace can be highly beneficial for organizations that require stringent security controls and resource isolation between projects or teams. However, this should be balanced with the operational complexity and overhead it might introduce.

## Q:

What about the rest of the required roles in the cluster-wide advise earlier?


## A: 

For a namespace-scoped GitLab Runner using Role and RoleBinding, the scope of permissions would need to be adjusted to fit within the namespace while still providing sufficient privileges for typical CI/CD tasks. Here’s how you can adapt the broader cluster-wide permissions into a namespace-specific Role definition:

### Namespace-Specific Role Configuration

This configuration includes permissions for handling typical Kubernetes objects that are required for most CI/CD operations within a namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: specific-namespace
  name: gitlab-runner-role
rules:
- apiGroups: ["", "apps", "batch", "extensions", "networking.k8s.io"]
  resources: ["deployments", "replicasets", "pods", "services", "configmaps", "secrets", "persistentvolumeclaims", "ingresses", "jobs", "cronjobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "create", "update", "delete"]
```
- [Configure runner API permissions](https://docs.gitlab.com/runner/executors/kubernetes/#configure-runner-api-permissions)
- @ `values.yaml` : "`rbac.create: true`", "`rbac.rules: []`"

### Explanation of Roles

- **Pods and Deployments**: Essential for deploying and managing applications and their scaling.
- **ReplicaSets**: Necessary for managing the lifecycle of pods that are created by deployments.
- **Services**: Required for creating and managing network access to the pods, a common requirement in deployments.
- **ConfigMaps and Secrets**: Often used to manage configuration data and secrets for applications, respectively.
- **PersistentVolumeClaims**: For managing storage used by the pods.
- **Ingresses**: Important for managing external access to services within the namespace.
- **Jobs and CronJobs**: Useful for tasks like database migrations, batch jobs, or scheduled tasks that are part of application management.
- **HorizontalPodAutoscalers**: For applications that need to scale based on load or other metrics.

### RoleBinding Configuration

To apply these permissions, the Role must be bound to the Service Account used by the GitLab Runner:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner-rolebinding
  namespace: specific-namespace
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: specific-namespace
roleRef:
  kind: Role
  name: gitlab-runner-role
  apiGroup: rbac.authorization.k8s.io
```

### Considerations for Namespace-Specific Roles

- **Security**: This approach minimizes the risk of impacting resources outside the designated namespace.
- **Flexibility**: It allows each team or project to have tailored CI/CD pipelines that align with their specific needs and constraints.
- **Management**: While more granular control is beneficial for security and organizational purposes, it also requires more detailed management of permissions and configurations.

By defining a comprehensive Role as shown, you ensure that your GitLab Runner has all necessary permissions to perform typical CI/CD tasks within a specific namespace, maintaining both flexibility and security.

# Resource limits | [GitLab Runner on K8s by Helm chart](https://docs.gitlab.com/runner/install/kubernetes/)

## Q:
How and where to set resource limits __on the ephemeral child pods__ of GitLab Runners where the pipelines actually run?

## A:

For ephemeral child pods of GitLab Runners, resource limits can be set at multiple levels to ensure proper resource allocation and prevent overconsumption. These limits should be defined in the **GitLab Runner configuration** as well as in the **Kubernetes namespace or policy level**.

---

### **1. Configure Resource Limits in GitLab Runner ConfigMap**
GitLab Runner dynamically spawns Kubernetes pods for each job. Resource limits can be set in the runner's **ConfigMap** under `.spec.config.runnerRegistration.config.kubernetes`.

Edit the GitLab Runner **ConfigMap** in the namespace where your runner is deployed:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-runner
  namespace: gitlab
data:
  config.toml: |
    [[runners]]
      executor = "kubernetes"
      [runners.kubernetes]
        cpu_request = "500m"   # Minimum CPU requested
        cpu_limit = "1000m"    # Maximum CPU allowed
        memory_request = "512Mi"  # Minimum memory requested
        memory_limit = "1024Mi"   # Maximum memory allowed
```
- @ `values.yaml`, the `runners.config` key is the `config.toml`

Then, restart the runner:

```sh
kubectl delete pod -n gitlab -l app=gitlab-runner
```

---

### **2. Define Resource Limits in the Kubernetes `values.yaml` (for Helm deployments)**
If you deployed GitLab Runner using Helm, set the resource limits in the `values.yaml` file:


```yaml
runners:
  config: |
    [[runners]]
      name = "gitlab-k8s-runner"
      executor = "kubernetes"
      [runners.kubernetes]
        cpu_request = "500m"
        cpu_limit = "1"
        memory_request = "512Mi"
        memory_limit = "1024Mi"

```
- @ [`values.yaml`](https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml)
- [Advanced configuration : runners](https://docs.gitlab.com/runner/configuration/advanced-configuration/#the-global-section)
Then upgrade the deployment:

```sh
helm upgrade --install gitlab-runner gitlab/gitlab-runner -f values.yaml
```

---

### **3. Use Kubernetes ResourceQuotas and LimitRanges (Namespace-Level Control)**

To enforce constraints at the namespace level, define `ResourceQuota` and `LimitRange`:

- **ResourceQuota** __limits the total__ available resources __per namespace__. 
   Useful in multi-tenancy, when several users or teams share a cluster with a fixed number of nodes, 
   there is a concern that one team could use more than its fair share of resources.
- **LimitRange** sets __default__ resource requests and limits per pod in the namespace.

Create a `ResourceQuota`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: gitlab-runner-quota
  namespace: gitlab
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "4Gi"
    limits.cpu: "8"
    limits.memory: "8Gi"
```

Create a `LimitRange`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: gitlab-runner-limits
  namespace: gitlab
spec:
  limits:
    - default:
        cpu: "1000m"
        memory: "1024Mi"
      defaultRequest:
        cpu: "500m"
        memory: "512Mi"
      type: Container
```

Apply them:
```sh
kubectl apply -f resourcequota.yaml
kubectl apply -f limitrange.yaml
```

---

### **4. Dynamic Overrides in `.gitlab-ci.yml`**
Pipeline jobs can request specific resources by using **CI/CD variables**:

```yaml
test-job:
  script:
    - echo "Running tests"
  tags:
    - kubernetes
  variables:
    KUBERNETES_CPU_REQUEST: "750m"
    KUBERNETES_CPU_LIMIT: "1500m"
    KUBERNETES_MEMORY_REQUEST: "768Mi"
    KUBERNETES_MEMORY_LIMIT: "2Gi"
```

---

### **Conclusion**
- **Set default limits in GitLab Runner (`config.toml`)**.
- **Apply namespace-level restrictions (`ResourceQuota`, `LimitRange`)** for better control.
- **Allow per-job overrides in `.gitlab-ci.yml`** for flexibility.
