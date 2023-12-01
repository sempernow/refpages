# [Kubernetes : HostPath](https://chat.openai.com/share/0001b54f-cd7a-488a-881c-576d5335ac7f "ChatGPT")

HostPath is the Kubenetes equivalent to Docker's bind mount. 
Must restrict pod to same node (host) as the volume.

@ Pod manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  nodeName: specific-node-name
  containers:
    - name: my-container
      image: your-container-image
      volumeMounts:
        - name: host-path-volume
          mountPath: /path/in/container  # Mount path inside the container
  volumes:
    - name: host-path-volume
      hostPath:
        path: /path/on/host  # Path on the specific node you want to bind

```




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

