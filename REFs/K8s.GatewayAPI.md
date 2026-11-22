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

---

Using a dedicated subdomain per team (e.g., `a.company.com` and `b.company.com`) is the industry standard for multi-tenant Kubernetes environments. It is the cleanest way to enforce security boundaries, automate DNS, and isolate traffic.

## Why Subdomains Work Best in Practice

1. Clean RBAC Boundaries: You can delegate the entire subdomain infrastructure to a specific namespace. Team A owns everything under *.team-a.company.com, and their RBAC permissions prevent them from touching Team B's domain.
2. Wildcard DNS & TLS Simplified: The infrastructure team can provision a single wildcard certificate (*.company.com or *.apps.company.com) on the shared Gateway. Teams can then spin up new applications instantly without requesting new SSL certificates.
3. No Path Conflicts: Implementing multi-tenancy via URL paths (e.g., company.com vs company.com) is highly error-prone. Applications often break because they expect to run at the root path (/), messing up relative assets like images, scripts, and internal redirects.

------------------------------

## How to Implement This with the Gateway API

In a real production environment, this is achieved by combining a central Gateway with wildcard constraints and individual team HTTPRoutes.

## 1. The Platform Team Configures the Central Gateway

The infrastructure team creates a single Gateway in an admin namespace (e.g., infra). They use allowedRoutes to let other namespaces attach to it, but they restrict the hostnames each namespace can claim.

```yaml
apiVersion: gateway.networking.k8s.io/v1kind: Gatewaymetadata:
  name: shared-gateway
  namespace: infraspec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: https-teama
    protocol: HTTPS
    port: 443
    hostname: "*.team-a.company.com" # Locks this listener to Team A's subdomain
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            kubernetes.io/metadata.name: team-a # Only allows the team-a namespace
    tls:
      mode: Terminate
      certificateRefs:
      - name: teama-wildcard-tls
```

## 2. Team A Configures Their App Route

Developers in the team-a namespace can now deploy their applications safely. If they try to claim a domain outside of their assigned wildcard, the Gateway will reject it.

```yaml
apiVersion: gateway.networking.k8s.io/v1kind: HTTPRoutemetadata:
  name: billing-app
  namespace: team-a # Must match the allowed namespace abovespec:
  parentRefs:
  - name: shared-gateway
    namespace: infra
  hostnames:
  - "billing.team-a.company.com" # Must fit inside the *.team-a.company.com rule
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: billing-service
      port: 80
```

------------------------------

## Alternative: Dedicated Gateways Per Team

While sharing a single large Gateway is common, some enterprise organizations choose to deploy one Gateway instance per team.

* Each team gets their own dedicated load balancer IP.
* This provides complete network and noisy-neighbor isolation.
* The Gateway API easily supports this because Gateway resources themselves are namespace-scoped. 
  Team A can have a Gateway in the `team-a` namespace, and Team B can have one in `team-b`.


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

