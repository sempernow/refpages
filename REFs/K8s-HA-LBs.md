
# Load Balancer Considerations : On-premesis Kubernetes Cluster

## `/readyz` vs `/livez` 

What happens if etcd on one node fails, but its API server remains running?

-  The API server may still be listening on port `6443`.
-  Its `/livez` check may pass, while `/readyz` fails due to `etcd` being unavailable.
-  The remaining `etcd` members still maintain quorum, keeping the `etcd` cluster operational.
-  Yet API requests reaching the affected API server may fail because it cannot access its configured `etcd` endpoint.

Here’s where it gets interesting.

If the load balancer only checks `TCP` port `6443`, it may continue sending traffic to the affected API server, 
causing requests requiring `etcd` to fail or time out.

So, ***even with `etcd` quorum and multiple API servers, clients can still experience failures**.

### Key takeaway: 

Load balancer health checks should use `/readyz`, not just a TCP port check, 
to verify that an API server is actually ready to handle requests.

Using **HAProxy / Keepalived** for HA NLB

In this architecture, the **`/readyz` check should be configured in HAProxy, not in Keepalived**. 
Keepalived should only be responsible for checking whether the HAProxy process itself is alive.

These two components have distinct responsibilities:

### 🎯 HAProxy: Responsible for Backend Health Checks (Use `/readyz`)
HAProxy acts as the load balancer and is directly responsible for deciding which Kubernetes API Server it forwards traffic to. Therefore, health checks at this layer should target the actual readiness of the **backend API Server**.

- **Why use `/readyz`**: The `/readyz` endpoint can accurately reflect whether the API Server can accept traffic (for example, if it is waiting for etcd to become available, it will return a failure status). This is more precise than simply checking if the TCP port is open. When an API Server is shutting down gracefully or is temporarily unavailable, HAProxy can remove it from the backend list in a timely manner to ensure traffic is only sent to healthy nodes.
- **How to configure**: In the `backend` section of HAProxy, use `option httpchk GET /readyz` and expect a status code of `200`.

### 🛡️ Keepalived: Responsible for HAProxy's Own Liveness Check
Keepalived is responsible for managing the VIP (Virtual IP). It decides whether to move the VIP to another node.

- **Check target**: The script executed by Keepalived should target **the local HAProxy instance**, not directly target the Kubernetes API Server's `/readyz`.
- **Reason**: If Keepalived also checks `/readyz`, it creates a logical conflict. When all backend API Servers have issues (for example, etcd cluster failure), every node's Keepalived will think "the backend is unhealthy," potentially causing the VIP to drift between nodes or even preventing the VIP from being held anywhere, causing a complete service outage. Checking the HAProxy process (or HAProxy's own monitoring endpoint `/healthz`) ensures that as long as the machine is alive and HAProxy is functioning, the VIP remains stable, while the actual traffic routing decisions are handled by HAProxy.

**Summary**: Use HAProxy for `/readyz` to make **traffic routing** decisions; use Keepalived to check **HAProxy's liveness** to make **VIP drift** decisions.

---

keepalived configuration:

    vrrp_script chk_haproxy {
        script "/etc/keepalived/check_apiserver.sh"   # cURLs localhost:8443/readyz via haproxy
        interval 3
        fall 3
        rise 2
        weight -20        # or omit weight to go FAULT outright
    }


haproxy configuration:

    backend k8s-api
        mode tcp
        option httpchk GET /readyz
        http-check expect status 200
        default-server check check-ssl verify none inter 2s fall 3 rise 2
        server cp1 10.0.0.11:6443
        server cp2 10.0.0.12:6443
        server cp3 10.0.0.13:6443

#### Notes regarding STIG environments

In HAProxy the health check is configured separately from the proxy mode, so a `mode tcp` backend can still run an HTTP(S) check. Client traffic is passed through as raw TCP with TLS end-to-end to the apiserver, while the check itself opens its own TLS connection and sends `GET /readyz`.

A few details decide whether it works:

- **Use `check-ssl`, not `ssl`.** `check-ssl` wraps only the health check in TLS. `ssl` on the server line would make HAProxy re-encrypt the proxied traffic itself, which you don't want in passthrough mode. Without `check-ssl`, the check is sent as plain HTTP to a TLS-only port and fails.
- **Certificate verification.** `verify none` is the quick option. Under STIG, prefer `verify required ca-file /etc/kubernetes/pki/ca.crt`, and add `check-sni` if the apiserver cert's SANs don't include the backend IP.
- **Syntax depends on HAProxy version.** RHEL 8 ships HAProxy 1.8 and RHEL 9 ships 2.4.
  - 1.8: legacy `option httpchk GET /readyz` plus `http-check expect status 200`.
  - 2.2+: the newer form is clearer:

```conf
backend k8s-api
    mode tcp
    option httpchk
    http-check connect ssl
    http-check send meth GET uri /readyz ver HTTP/1.1 hdr Host kubernetes
    http-check expect status 200
    default-server check check-ssl verify required ca-file /etc/haproxy/k8s-ca.crt inter 2s fall 3 rise 2
    server cp1 10.0.0.11:6443
    server cp2 10.0.0.12:6443
    server cp3 10.0.0.13:6443
```

- **Client cert for `anonymous-auth=false`.** Add `crt /etc/haproxy/health-client.pem` to `default-server`. It applies only to check connections, because proxied traffic is never TLS-terminated by HAProxy in TCP mode.

With this setup the frontend stays `mode tcp` with no TLS termination at the load balancer, kubectl client certs still reach the apiserver untouched, and you still get `/readyz`-based draining.


**Both, but they check different things. HAProxy checks `/readyz` on each apiserver. Keepalived checks whether the local HAProxy can actually serve traffic.** Keepalived should not check `/readyz` on the local apiserver directly.

### Why keep the layers separate

- **HAProxy owns backend health.** Its job is to drop a dead or draining apiserver from rotation. `/readyz` is the right endpoint because it returns 503 during graceful shutdown (`--shutdown-delay-duration`), so HAProxy drains a node before it disappears.
- **Keepalived owns VIP placement.** The only question it needs to answer is "should this node hold the VIP?" That depends on whether the local HAProxy can proxy, not on whether the co-located apiserver is up.

If keepalived checked the local apiserver's `/readyz`, one apiserver restart would move the VIP even though that node's HAProxy could still route to the other two backends. That's an unnecessary failover. If all apiservers are down, the VIP would bounce between nodes for no benefit.

### The kubeadm-recommended pattern

The kubeadm HA guide (`ha-considerations.md`) has keepalived's `check_apiserver.sh` curl through the HAProxy frontend (`https://localhost:<haproxy_port>/`), not the local apiserver port. That one check confirms two things: the HAProxy process is up, and it has at least one healthy backend. Do it that way.

```conf
vrrp_script chk_haproxy {
    script "/etc/keepalived/check_apiserver.sh"   # curls localhost:8443/readyz via haproxy
    interval 3
    fall 3
    rise 2
    weight -20        # or omit weight to go FAULT outright
}
```

```conf
backend k8s-api
    mode tcp
    option httpchk GET /readyz
    http-check expect status 200
    default-server check check-ssl verify none inter 2s fall 3 rise 2
    server cp1 10.0.0.11:6443
    server cp2 10.0.0.12:6443
    server cp3 10.0.0.13:6443
```


The Kubernetes STIG requires `--anonymous-auth=false`. With that set, unauthenticated `/readyz` checks get a 401 and every backend goes DOWN. You have three options:

1. **Anonymous access limited to health endpoints only.** Use structured `AuthenticationConfiguration` with `anonymous.enabled: true` and `conditions` set to `/readyz`, `/livez`, and `/healthz`. This was added around v1.32, so check that your version supports it, and confirm with your assessor that it satisfies the STIG finding.
2. **Client cert on the health check.** Use `check-ssl crt /etc/haproxy/health-client.pem` with a cert bound to a minimal RBAC role that can only read the health endpoints. This is the cleanest option for a strict STIG posture.
3. **Fall back to a plain TCP check.** This is simple but loses the graceful-drain behavior of `/readyz`.

The same auth issue applies to the keepalived script's curl, because that request passes through HAProxy to the apiserver.

---

# Q:

How does MetalLB rate relative to the HAProxy-Keepalived scheme for on-prem Kubernetes HA load balancers?
ChatGPT

# A:

Both MetalLB and the HAProxy-Keepalived scheme are popular solutions for implementing high availability (HA) load balancers in an on-premesis Kubernetes environment. 

Each has its own strengths and considerations. Let's compare them:

MetalLB:

    Native Kubernetes Integration: MetalLB is a Kubernetes-native solution, meaning it integrates seamlessly with the Kubernetes API and can be configured using standard Kubernetes resources like Services of type LoadBalancer. This can make it easier to manage and fits well into the Kubernetes ecosystem.

    Dynamic IP Address Allocation: MetalLB can dynamically allocate IP addresses from a given range to services of type LoadBalancer. This can be beneficial in environments where IP addresses are scarce or where you want the flexibility to allocate and release IP addresses as needed.

    BGP Support: MetalLB supports both BGP (Border Gateway Protocol) and ARP (Address Resolution Protocol) modes for announcing IP addresses to the network. BGP is particularly useful in large-scale deployments and environments where dynamic routing is preferred.

HAProxy-Keepalived Scheme:

    Manual Configuration: HAProxy and Keepalived require manual configuration and management of HAProxy instances and Keepalived nodes. While this offers fine-grained control, it may involve more manual intervention compared to MetalLB's more automated approach.

    Flexibility: HAProxy is a powerful and flexible load balancer that can be highly customized to meet specific requirements. It provides a wide range of features and supports various load balancing algorithms.

    Active-Passive Setup: The HAProxy-Keepalived scheme often involves an active-passive setup where one node is active while others are in standby. Keepalived monitors the health of the active node and can switch to a standby node in case of a failure. This setup ensures high availability.

Considerations:

    Ease of Use: MetalLB is generally easier to set up and manage, especially for users already familiar with Kubernetes concepts. HAProxy-Keepalived may require more manual configuration and maintenance.

    Scalability: MetalLB is designed to scale with Kubernetes clusters and provides a more automated and scalable solution. HAProxy-Keepalived may require more manual intervention to scale.

    Features: If advanced load balancing features are required, HAProxy provides a rich set of features and fine-grained control over configurations.

For a highly available Kubernetes cluster, where the cluster entrypoint needs to remain stable even under node failures, the choice of load balancer becomes crucial. Here are some considerations for load balancers that can help maintain high availability:

    MetalLB with BGP Mode:
        Description: MetalLB, as mentioned earlier, is a popular Kubernetes-native load balancer. When configured in BGP mode, MetalLB can provide a highly available setup where IP addresses are dynamically advertised using BGP to the external network.
        Advantages:
            BGP provides dynamic routing, allowing for quick detection and redirection of traffic in case of node failures.
            MetalLB's BGP mode is designed to provide high availability and stability for the cluster entrypoint.

    NGINX Ingress Controller with External TCP/UDP Services:
        Description: The NGINX Ingress Controller can be configured to handle external TCP or UDP services, effectively acting as an external load balancer.
        Advantages:
            NGINX can be set up with multiple replicas and can handle failovers in a highly available manner.
            External TCP/UDP services provide a stable entrypoint for traffic, and NGINX can be configured to distribute traffic among healthy nodes.

    HAProxy Ingress with ExternalTrafficPolicy:
        Description: HAProxy Ingress, coupled with the ExternalTrafficPolicy feature in Kubernetes, can help maintain stable entrypoints during node failures.
        Advantages:
            ExternalTrafficPolicy ensures that external traffic is only sent to nodes with running pods, reducing the impact of node failures on the load balancer's stability.
            HAProxy's capabilities for load balancing and failover can be leveraged for maintaining high availability.

    Envoy Proxy with a Service Mesh (e.g., Istio):
        Description: Envoy Proxy, when used as part of a service mesh like Istio, can provide a robust and highly available traffic management solution.
        Advantages:
            Service mesh capabilities, such as traffic splitting, can help distribute traffic intelligently among healthy nodes.
            Istio, for example, has built-in features for traffic management, load balancing, and failover.

When designing for high availability, it's essential to consider the specific features and configurations of each load balancer, as well as the overall architecture of your Kubernetes cluster. Additionally, monitoring, alerting, and testing the failover mechanisms are crucial aspects of ensuring that your load balancer can effectively handle node failures and maintain a stable entrypoint to the cluster.
