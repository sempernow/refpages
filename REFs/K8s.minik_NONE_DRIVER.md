# `minikube start --vm-driver=none` : 2018 Notes

Minikube supports a [`none` driver option](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-a-hypervisor) that runs the Kubernetes components [on the host and not in a VM](https://github.com/kubernetes/minikube#linux-continuous-integration-without-vm-support "Linux Continuous Integration without VM Support [Install-method @ GitHub]").   

Using this driver __requires Docker__, but __not a hypervisor__. The option has __security issues__, as it reports ...  

```powershell
# Driver option: NONE 
PS> minikube start --vm-driver=none  
```
### ... _reports_ ...
```
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
===================
WARNING: IT IS RECOMMENDED NOT TO RUN THE NONE DRIVER ON PERSONAL WORKSTATIONS
        The 'none' driver will run an insecure kubernetes apiserver as root that may leave the host vulnerable to CSRF attacks

When using the none driver, the kubectl config and credentials generated will be root owned and will appear in the root home directory.
You will need to move the files to the appropriate location and then set the correct permissions.  An example of this is below:

        sudo mv /root/.kube $HOME/.kube # this will write over any previous configuration
        sudo chown -R $USER $HOME/.kube
        sudo chgrp -R $USER $HOME/.kube

        sudo mv /root/.minikube $HOME/.minikube # this will write over any previous configuration
        sudo chown -R $USER $HOME/.minikube
        sudo chgrp -R $USER $HOME/.minikube

This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
Loading cached images from config file.
```  

## Tested per (`minik.ps1`) QuickStart ([MD](Kubernetes.QuickStart.md "Kubernetes.QuickStart.md") | [HTML](Kubernetes.QuickStart.html "@ browser"))
### `kubectl` tool appears to work

```powershell
PS> kubectl get pod
NAME                             READY     STATUS  ...
hello-minikube-6c47c66d8-rm5bp   1/1       Running ...
```

### Public address is inaccessible 

```powershell
PS> curl $(minikube service hello-minikube --url)
curl : Unable to connect to the remote serve 
# IP:PORT
PS> minikube service hello-minikube --url
http://192.168.1.11:31750
```
