# Hello Minikube :: [QuickStart](https://kubernetes.io/docs/setup/minikube/#quickstart) 

A one-pod cluster exposed to the standard HTTP listening port. 

```powershell 
# Start cluster 
$ minikube start # --vm-driver=none # mode; See ..Install
# Apply deployment; a pod exposed to port 8080
$ kubectl create hello-minikube --image=k8s.gcr.io/echoserver:1.4 --port=8080 
deployment.apps "hello-minikube" created  
# Expose an endpoint per NodePort
$ kubectl expose deployment hello-minikube --type=NodePort
service "hello-minikube" exposed
# Get status (multiple times) as pod is created/configured
$ kubectl get pods
hello-minikube-6c47c66d8-zmd8z... ContainerCreating... Running
# Get public IP:PORT
$ minikube service hello-minikube --url
http://192.168.1.105:31233
# Request/Response from HTTP server, per curl ...
$ curl $(minikube service hello-minikube --url)
StatusCode        : 200
...
# Cleanup
$ kubectl delete services hello-minikube
service "hello-minikube" deleted
$ kubectl delete deployment hello-minikube
deployment.extensions "hello-minikube" deleted
# Turn off the Minikube; the cluster's VM
$ minikube ssh   # into VM
$ sudo poweroff  # from inside VM
```

- If Minikube on Hyper-V (Windows), then use PowerShell terminal, and work from SystemDrive
.