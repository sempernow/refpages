# [Google Cloud Platform (GCP)](https://cloud.google.com/products/ "GCP Products")
## [`gcloud` SDK](https://cloud.google.com/sdk/docs/)

## Kubernetes :: Google Kubernetes Engine (GKE) 

### @ Create Cluster  

-  Node image   
`cos`: Container Optimized; based on Chromium OS  
`container-vm`; legacy; Debian-based

- Size  
The number of Minions  
    GKE handles the Master, as GKE is a managed service.  

- Automatic Upgrates (beta)  
Allow GKE to manage nodes.

- More   
A bazillion options.

- Equivalent REST or [gcloud](https://cloud.google.com/sdk/gcloud/) command line    
Code equiv to GUI selections; downloadable

### @ `gcloud` shell

```bash
gcloud container clusters list
```
### Configure `kubectl` @ `gcloud` to use the cluster.  
- "Connect to cluster" (link)  
Copy/Paste command into gcloud shell ...

```bash 
kubectl get nodes 
```

### Login to cluster Dashboard (Web UI)  
https://IP_ADDR/ui

Get URL and password @ GKE console  
1. Endpoint: IP_ADDR  
2. "Show credentials" (link)  


### &nbsp;
