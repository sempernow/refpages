# RKE2 : [`docs.rke2.io`](https://docs.rke2.io/) | [GitHub : `/rancher/rke2`](https://github.com/rancher/rke2)


```bash
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
# Wait a bit
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/var/lib/rancher/rke2/bin
kubectl get nodes
```




### &nbsp;
