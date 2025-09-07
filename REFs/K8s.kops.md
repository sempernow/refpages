# [`kops`](https://kops.sigs.k8s.io/ "kops.sigs.k8s.io") (Kubernetes OPerationS) | [GitHub](https://github.com/kubernetes/kops "kubernetes/kops")

A CLI for deploying a cluster to certain cloud vendors. 
A wrapper for Kubernetes tools and cloud-provider APIs. 
Create, destroy, upgrade and maintain production-grade Kubernetes clusters. 

Currently available for AWS, GCP, DigitalOcean, and Hetzner. 

Using this tool, expect a highest-cost implementation. 
That is, wherever there is a choice between a premium option 
and a lesser-cost option of any cloud-service dependency, 
expect it to select the former.

## [Install @ Ubuntu (`kops.sh`)](kops.sh) 

## Install @ [Vagrant box](https://app.vagrantup.com/boxes/search?provider=hyperv&q=ubuntu&sort=downloads&utf8=%E2%9C%93 "Vagrant Boxes : Ubuntu @ hyperv") (VM)
- [See `kops.sh`](kops.sh)   
@ `Vagrantfile` per __Script Provisioner__  

    ```ruby 
    config.vm.provision "shell", path: "kops.sh", privileged: false
    ```

## Project(s)  

-  `PRJ.K8s.kops@AWS` ([MD](PRJ.K8s.kops@AWS.html "@ browser"))  

## References 

- [`kops` commands reference (`.md` docs)](https://github.com/kubernetes/kops/tree/master/docs/cli "GitHub/kops/.../cli")

- [`kops`/`ingress-nginx`](https://github.com/kubernetes/kops/tree/master/addons/ingress-nginx "GitHub/kubernetes/kops/ingress-nginx")

- [AWS-ELB-specific `LoadBalancer` configurations](https://kubernetes.io/docs/concepts/services-networking/service/#connection-draining-on-aws).


## [Getting Started](https://github.com/kubernetes/kops/blob/master/docs/aws.md "GitHub/Kubernetes/kops")

### Create
```bash
export NAME='k8s01.example.com'
export KOPS_STATE_STORE=s3://foo.com-abc123-state-store
# Create (builds within ASGs, so monitored/rebuilt on fail)
kops create cluster --zones 'us-east-1e' $NAME
# Edit (loads from S3 state store bucket)
kops edit cluster $NAME  # per $EDITOR
# Build (resources)
kops update cluster $NAME --yes
```

- Another kops Env.Var.

    ```bash
    # Export, so needn't include NAME @ every command
    export KOPS_CLUSTER_NAME=$NAME
    ```

### View
```bash
# kops generates creds for kubectl
cat ~/.kube/config

# Validate
kops validate cluster
# List all clusters 
kops get clusters
# List  machines (master + workers)
kops get instancegroups
# List nodes
kubectl get nodes
# List system components
kubectl -n kube-system get po
```

### Delete
```bash
# View resources to be destroyed
kops delete cluster --name ${NAME}
# Delete everything (all cluster resources)
kops delete cluster --name ${NAME} --yes
```

### [Other interesting modes](https://github.com/kubernetes/kops/blob/master/docs/commands.md#other-interesting-modes "GitHub/kops")

```bash
# Build a terraform model: 
    --target=terraform 
# Build a Cloudformation model: 
    --target=cloudformation # json @ 'out/cloudformation'
# Specify k8s build: 
    --kubernetes-version=1.2.2
# Run nodes in multiple zones: 
    --zones=us-east-1b,us-east-1c,us-east-1d
# Run with a HA master: 
    --master-zones=us-east-1b,us-east-1c,us-east-1d
# Specify the number of nodes: 
    --node-count=4
# Specify the node size: 
    --node-size=m4.large
# Specify the master size: 
    --master-size=m4.large
# Override the default DNS zone: 
    --dns-zone=$_DOMAIN
```


### &nbsp;