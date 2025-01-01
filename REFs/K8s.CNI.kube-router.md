# [`kube-proxy`](https://github.com/cloudnativelabs/kube-router/)

Kube-router uses IPVS/LVS technology built in Linux to provide L4 load balancing. 
Each ClusterIP, NodePort, and LoadBalancer Kubernetes Service type 
is configured as an IPVS virtual service. 
Each Service Endpoint is configured as real server to the virtual service. 
The standard `ipvsadm` tool can be used to verify the configuration and monitor the active connections.

## [Docs](https://github.com/cloudnativelabs/kube-router/tree/master/docs)

- [How it works](https://github.com/cloudnativelabs/kube-router/blob/master/docs/how-it-works.md)
- [Deploying kube-router with kubeadm](https://github.com/cloudnativelabs/kube-router/blob/master/docs/kubeadm.md)