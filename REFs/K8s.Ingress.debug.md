# Debug Ingress failures


Here is the targeted debugging checklist for Kubernetes Ingress failure modes, structured by the exact HTTP status codes you will encounter.

## HTTP 503 Service Unavailable

A 503 means the Ingress controller is active, but it **cannot find any healthy pods** to route the traffic to. [1, 2] 

* Check **Endpoint Routing**: Run `kubectl get endpoints <service-name>` to verify that your Service has IP addresses assigned to it.
* Inspect **Health Checks**: Run `kubectl describe pod <pod-name>` to check if Readiness Probes are failing. Unready pods are pulled from the endpoint list.
* Verify **Selector-Labels Match**: Ensure the `spec.selector` labels in your `Service` YAML exactly match the `.metadata.labels` defined in your `Deployment`'s **pod template**.
* Check **Namespace Alignment**: Confirm your Ingress resource and your Service resource are deployed in the exact same namespace. [3, 4, 5, 6, 7] 

## HTTP 502 Bad Gateway

A 502 means the Ingress controller **successfully reached a pod, but the network connection was refused or dropped instantly**. [8] 

* Audit **Port Configurations**: Verify that the `service.port.number` in your Ingress matches the `containerPort` in your Pod template. A mismatch causes immediate connection refusal. [9, 10, 11] 
* Review **Controller Logs**: Run `kubectl logs -n <ingress-namespace> <ingress-controller-pod>` to see the exact upstream connection error. [12] 
* Test **Internal Connectivity**: Launch a temporary curl pod inside the cluster to test if you can reach the backend Service IP directly bypass-passing the Ingress. [13] 
* Check **Scheme Mismatch**: If your backend application expects HTTPS but the Ingress controller is trying to talk to it via HTTP (or vice versa), the handshake will fail.

## HTTP 504 Gateway Timeout

A 504 means the Ingress controller successfully routed the request to the pod, but the **pod took too long to respond** and exceeded the proxy's timeout limit. [14] 

* Increase **Ingress Timeouts**: Add the appropriate annotation to your Ingress resource to bump the timeout limits 
  (e.g., `nginx.ingress.kubernetes.io/proxy-read-timeout: "600"` for NGINX).
* Check **Pod Resource Starvation**: Run `kubectl top pods` to see if your backend container is hitting its CPU limits or swapping memory, stalling execution.
* Inspect **DB / Third-Party Locks**: Review application logs to determine if the backend pod is hanging on a slow database query or an external API dependency. [15, 16, 17, 18, 19] 

## HTTP 404 Not Found

A 404 means the Ingress controller is working, but it **does not recognize the Host or Path** specified in your request. [20] 

* Validate **Ingress Class**: Run `kubectl get ingress` and verify that the CLASS column matches your cluster's controller (e.g., nginx). If blank, add the `spec.ingressClassName` field.
* Verify **Host Header**: Ensure your curl request or browser matches the `spec.rules[].host` defined in your Ingress YAML exactly.
* Check **Path Formatting**: Verify the `spec.rules[].http.paths[].pathType`. If using `Exact`, ensure trailing slashes match perfectly; if using `Prefix`, verify your application can handle the sub-paths. [21, 22, 23, 24, 25] 



[1] [https://itnext.io](https://itnext.io/kubernetes-503-errors-with-aws-alb-possible-causes-and-solutions-decb71988514)
[2] [https://github.com](https://github.com/kubernetes/ingress-nginx/issues/250)
[3] [https://www.plural.sh](https://www.plural.sh/blog/best-practices-for-kubernetes-troubleshooting-with-ai/)
[4] [https://learnkube.com](https://learnkube.com/troubleshooting-deployments)
[5] [https://www.armosec.io](https://www.armosec.io/blog/debugging-in-kubernetes/)
[6] [https://medium.com](https://medium.com/@ismailkovvuru/fixing-502-errors-in-kubernetes-apps-on-aws-eks-a-devops-engineers-guide-361b90f65fb8)
[7] [https://www.netdata.cloud](https://www.netdata.cloud/academy/debugging-nginx-errors-inside-kubernetes/)
[8] [https://resolve.ai](https://resolve.ai/glossary/fixing-kubernetes-502-bad-gateway-error)
[9] [https://learnkube.com](https://learnkube.com/troubleshooting-deployments)
[10] [https://dev.to](https://dev.to/vikcodes/having-trouble-with-your-kubernetes-deployments-start-with-the-basics-4m02)
[11] [https://help.salesforce.com](https://help.salesforce.com/s/articleView?id=001115656&language=en_US&type=1)
[12] [https://supportfly.io](https://supportfly.io/how-to-fix-kubernetes-502-bad-gateway-load-error/)
[13] [https://www.alibabacloud.com](https://www.alibabacloud.com/help/en/ack/ack-managed-and-ack-dedicated/user-guide/alb-ingress-faq)
[14] [https://support.atlassian.com](https://support.atlassian.com/jira/kb/webhooks-or-web-requests-fail-with-http-status-code-400-401-or-403-in-jira/)
[15] [https://medium.com](https://medium.com/@akashjoffical08/investigating-a-possible-regression-backendconfig-timeoutsec-not-working-with-gce-ingress-in-gke-d26f84ec0811)
[16] [https://medium.com](https://medium.com/@devopsdiariesinfo/top-5-kubernetes-errors-and-how-to-fix-them-like-a-pro-20e64cbfc17d)
[17] [https://resolve.ai](https://resolve.ai/glossary/how-to-debug-kubernetes-probe-issues)
[18] [https://www.manageengine.com](https://www.manageengine.com/products/applications_manager/tech-topics/kubernetes-pod-monitoring.html)
[19] [https://www.ccbp.in](https://www.ccbp.in/blog/articles/kubernetes-interview-questions)
[20] [https://medium.com](https://medium.com/@theodorahcheng/kubernetes-ingress-101-troubleshooting-ingress-5f2be086cca3)
[21] [https://palark.com](https://palark.com/blog/k8sgpt-ai-troubleshooting-kubernetes/)
[22] [https://vadosware.io](https://vadosware.io/post/serving-http-applications-on-kubernetes/)
[23] [https://ibrahims.medium.com](https://ibrahims.medium.com/kubernetes-errors-with-solution-ab3f5643c2dd)
[24] [https://jimmysong.io](https://jimmysong.io/blog/why-gateway-api-is-the-future-of-ingress-and-mesh/)
[25] [https://www.tencentcloud.com](https://www.tencentcloud.com/document/product/457/43504)



---

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
