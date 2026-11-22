# K8s Interview Questions


### **Basic Questions:**  

1. **Main components of a Kubernetes cluster?**  
   - Master Node (API Server, Controller Manager, Scheduler, etcd)  
   - Worker Nodes (Kubelet, Kube Proxy, Container Runtime)  

2. **What is a Pod?**  
   - The smallest deployable unit in Kubernetes, encapsulating one or more containers.  

3. **How does Kubernetes handle service discovery?**  
   - Through Services (`ClusterIP`, `NodePort`, `LoadBalancer`) and DNS resolution via `kube-dns` or CoreDNS.  

4. **Deployment vs. DaemonSet vs. StatefulSet?**  
   - **Deployment**: Manages stateless applications.  
   - **DaemonSet**: Ensures one Pod per node.  
   - **StatefulSet**: Manages stateful applications with persistent identity.  

5. **Role of etcd?**  
   - A distributed key-value store for cluster state and configuration.  

6. **Namespaces in Kubernetes?**  
   - Logical partitions for resource isolation within a cluster.  

7. **Service vs. Ingress?**  
   - **Service**: Exposes Pods internally or externally.  
   - **Ingress**: Manages HTTP/S traffic via rules.  

8. **ConfigMaps vs. Secrets?**  
   - **ConfigMap**: Stores non-sensitive config data.  
   - **Secret**: Stores sensitive data, encoded in Base64.  

### **Intermediate Questions:**  

9. **What happens when a node fails?**  
   - Pods are rescheduled on other nodes; `node-controller` detects failure.  

10. **Rolling updates and rollbacks?**  
   - Deployments update Pods gradually; rollbacks restore previous versions.  

11. **How does HPA work?**  
   - Adjusts replica count based on CPU, memory, or custom metrics.  

12. **ClusterIP vs. NodePort vs. LoadBalancer?**  
   - **ClusterIP**: Internal access.  
   - **NodePort**: Exposes service on node IPs.  
   - **LoadBalancer**: Uses cloud provider’s LB.  

13. **Persistent Volumes (PVs) and Persistent Volume Claims (PVCs)?**  
   - PV: A provisioned storage resource.  
   - PVC: A request for storage by a Pod.  

14. **Readiness vs. Liveness probe?**  
   - **Readiness**: Checks if Pod is ready to accept traffic.  
   - **Liveness**: Checks if Pod is alive and should restart.  

15. **kubectl exec vs. kubectl logs?**  
   - `kubectl exec`: Run a command in a Pod.  
   - `kubectl logs`: Fetch container logs.  

16. **How does RBAC work?**  
   - Defines access control using `Roles`, `ClusterRoles`, `RoleBindings`, `ClusterRoleBindings`.  

### **Advanced Questions:**  

17. **How does Kubernetes schedule Pods?**  
   - Uses Scheduler based on node availability, resource requests, affinity rules.  

18. **How to troubleshoot a failing Pod?**  
   - Check logs (`kubectl logs`), events (`kubectl describe`), and probe failures.  

19. **How do Network Policies work?**  
   - Control Pod-to-Pod and Pod-to-external traffic using rules.  

20. **What is a sidecar pattern?**  
   - A helper container (e.g., logging, proxy) running alongside the main app in a Pod.  

21. **How does Kubernetes implement multi-tenancy?**  
   - Via Namespaces, RBAC, Network Policies, and Resource Quotas.  

22. **How to secure a Kubernetes cluster?**  
   - RBAC, Network Policies, TLS, Secrets encryption, Pod Security Policies.  

23. **How does Istio enhance networking?**  
   - Provides service mesh capabilities (traffic management, security, observability).  

24. **Challenges with Kubernetes in production?**  
   - Security, networking, monitoring, resource limits, auto-scaling complexities.  

25. **TLS in an air-gapped Kubernetes cluster?**  
   - Use cert-manager, custom CA, Vault, or manual certificate management.  



### &nbsp;
