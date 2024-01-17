# Kubernetes [Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/)

Dynamic infrastructure provisioning and advanced traffic routing.

Role-oriented (RBAC-based): Gateway API kinds are modeled after organizational roles::

- **Infrastructure Provider**:  
    Hypervisor Dev/Ops/Admin
- **Cluster Operator**:  
    Cluster Dev/Ops/Admin
- **Application Developer**:  
    App Dev/Ops/Admin

Gateway API `kind`s

1. **GatewayClass**: Defines a set of gateways with common configuration and managed by a controller that implements the class.

1. **Gateway**: Defines an instance of traffic handling infrastructure, such as cloud load balancer.

1. **HTTPRoute**: Defines HTTP-specific rules for mapping traffic from a Gateway listener to a representation of backend network endpoints. These endpoints are often represented as a Service.


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

