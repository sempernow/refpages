# Cloud Deployment :: Distributed Cache/Storage 

- Docker volumes are almost as worthless as bind mounts at multi-node swarm cluster; neither survive container lifecycle; new container of a service may spawn at other node (engine) and so may not have the same docker volume.
- REX-Ray volume plugin installs per vendor-specific driver; tested @ AWS (EBS), and supposedly works at DO too, but that's about all.
- Redis, as a single instance, is for ephemeral cache; does not survive container lifecycle. That is, no viable persistent storage under a multi-node swarm. (See Docker volumes issue, above.)
- Redis HA per Sentinel is a (candidate for) swarm-wide solution to cache and storage.
    - This involves a minimum of master, slave and sentinel. ___Clients connect only to sentinel___, which selects an apropos (functioning) master/slave.
    - Requires data initialization from the Source of Truth.
- MinIO is an S3-backed server (and adding new storage vendors), but no longer supports Docker Swarm; only the hellscape of Kubernetes.

## Read-only solutions 

1. Embed in Docker image 
1. Embed in Golang binary



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

