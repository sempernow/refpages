# Sonatype Nexus : NXRM

## Helm Charts

- OSS : [__`nexus3`__](https://artifacthub.io/packages/helm/stevehipwell/nexus3 "ArtifactHUB.io/.../stevehipwell/nexus3")
- Pro : [__`nxrm3-ha-repository`__](https://github.com/sonatype/nxrm3-ha-repository/tree/main/nxrm-ha "nxrm3-ha")


## URL Rewrite : `/` &rarr; `/nexus`

### Request &rarr; App

To configure **Nexus Repository Manager (NXRM)** running in **Kubernetes** with **Ingress-Nginx**, while ensuring the `/nexus` context path is preserved, follow these steps:


### **1. Update Nexus Configuration (Set Context Path)**
Since NXRM requires `/nexus` in its backend URLs, ensure the `nexus-context-path` is set correctly in the Pod.

#### **Option A: Using `nexus.properties` (ConfigMap or Volume Mount)**
1. **Create a ConfigMap** with `nexus.properties`:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: nexus-config
   data:
     nexus.properties: |
       nexus-context-path=/nexus  # Keep `/nexus` for backend compatibility
   ```
2. **Mount it in the Nexus Pod** (in your Deployment/StatefulSet):
   ```yaml
   volumes:
     - name: nexus-config
       configMap:
         name: nexus-config
   volumeMounts:
     - mountPath: /nexus-data/etc/nexus.properties
       subPath: nexus.properties
       name: nexus-config
   ```

#### **Option B: Use Environment Variable (For NXRM 3.30+)**
If your Nexus version supports it, override the context path via:
   ```yaml
   env:
     - name: NEXUS_CONTEXT_PATH
       value: /nexus
   ```

---

### **2. Configure Ingress-Nginx**
Use **rewrite annotations** to ensure `/nexus` is added to backend requests while hiding it from users.

#### **Example Ingress YAML**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nexus-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /nexus/$2
    nginx.ingress.kubernetes.io/proxy-redirect-from: "http://$host/nexus/"
    nginx.ingress.kubernetes.io/proxy-redirect-to: "http://$host/"
spec:
  ingressClassName: nginx
  rules:
  - host: nexus.lime.lan
    http:
      paths:
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: nexus-service  # Your Nexus Service name
            port:
              number: 8081      # Nexus default port
```

#### **Key Annotations Explained**:
- `rewrite-target: /nexus/$2`  
  Rewrites requests from `/` → `/nexus/` internally.
- `proxy-redirect-from/to`  
  Fixes redirects (e.g., when Nexus sends a `Location: /nexus/foo` header, it’s rewritten to `/foo`).

---

### **3. Verify Nexus Pod & Service**
Ensure your Nexus **Service** is correctly targeting the Pod:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nexus-service
spec:
  ports:
  - port: 8081
    targetPort: 8081
  selector:
    app: nexus
```

---

### **4. Test the Setup**
1. **Access Nexus** at `http://nexus.lime.lan/` (no `/nexus` visible).
2. **Check Backend Requests**:
   ```bash
   kubectl logs -l app.kubernetes.io/name=ingress-nginx --tail=100
   ```
   Look for requests to `/nexus/...` (rewrite working).

---

### **Troubleshooting**
- **404 Errors**: Ensure `nexus-context-path` is set to `/nexus` in the Pod.
- **Broken CSS/JS**: Add this annotation to fix static resources:
  ```yaml
  nginx.ingress.kubernetes.io/configuration-snippet: |
    sub_filter '/nexus/' '/';
    sub_filter_once off;
  ```
- **Redirect Loops**: Adjust `proxy-redirect-*` annotations or disable Nexus’s own redirects.

---

### **Final Notes**
- If Nexus still generates `/nexus`-prefixed links, consider patching its UI (advanced) or using a **custom reverse proxy** (e.g., Nginx sidecar).
- For Helm users (e.g., `sonatype/nexus-repository-manager`), override `nexusProperties` in `values.yaml`.



---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->
