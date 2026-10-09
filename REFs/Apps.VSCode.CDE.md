# CDE (**C**loud **D**evelopment **E**nvironment) using VSCode

## About

This is one of the primary benefits of using VS Code with a Kubernetes pod-based environment. 
You can directly edit the source code of a Git project that lives inside the pod, as if it were a local folder on your Windows machine.

The workflow generally falls into two main approaches, 
depending on whether you want to work **inside** the pod or run the code **locally** 
while connecting to the pod.

### Option 1: Edit Directly Inside the Pod (Remote Workspace)

In this setup, VS Code acts as a thin client, and all your files, terminals, and extensions actually live inside the pod. You get a full editing experience with syntax highlighting, IntelliSense, and Git integration that operates on the pod's filesystem.

*   **How to Connect**: You typically use the **Kubernetes** extension or the **Remote - Containers** extension. For a simple pod, the Kubernetes extension often provides an **"Attach to VSCode"** option when you right-click a running pod. For a more configured experience, you can define a `devcontainer.json` in your project, and VS Code will use `kubectl exec` to launch a development container session directly within the pod.
*   **Git Integration**: To use your Git credentials (like for pulling or pushing to a private repository) without copying your private keys into the container, you can use **SSH Agent Forwarding**. This allows the Git commands running inside the pod to use your local SSH keys securely.

### Option 2: Edit Locally, Run in the Cluster (Hybrid Approach)

This is a very powerful pattern where you keep your source code on your Windows machine and edit it locally in VS Code, but you run and debug that code as if it were inside the cluster. This avoids the "build-push-deploy" cycle for every change.

*   **How it Works**: Tools like **Telepresence** create a two-way network bridge between your local machine and the cluster. 
    You can "intercept" traffic meant for a service in the cluster, redirecting it to the process running on your laptop.
*   **The Benefit**: You use your local tools and debugger on your local code, 
    but your code can seamlessly access other services, environment variables, and volumes inside the cluster. 
    This is often preferred for Go and Python development because local file I/O and hot-reloading are much faster and more reliable than syncing files back and forth into a pod.

### Important Considerations

*   **Pods are Ephemeral**: Kubernetes pods are designed to be disposable. If a pod is deleted, restarted, or rescheduled, **any changes you made directly to files inside that pod will be lost**. For any code you want to keep, you must commit and push it to your Git repository. For this reason, the "Edit Locally, Run in Cluster" approach is often safer for long-term work.
*   **Performance on Windows**: If you choose the "Edit Locally" approach and mount your Windows filesystem into a container, file watching for hot-reload (e.g., with `nodemon` or Python's `watchdog`) can be very slow or unreliable due to the way Docker handles Windows file mounts. Running your code process natively on Windows (and using Telepresence to bridge to the cluster) avoids this issue entirely.


---

## Provision the Tools

For Option 1 (editing directly inside the pod), here's a clear breakdown of what to install and where.

### On Your Windows Machine

*   **VS Code**: The editor itself.
*   **VS Code Extensions**: You'll need two key extensions.
    *   **Kubernetes**: The official Microsoft extension (`ms-kubernetes-tools.vscode-kubernetes-tools`). It provides the cluster explorer and the "Attach to VSCode" command you'll use to connect to your pod .

    *   **Remote Development Pack**: This bundle (`ms-vscode-remote.vscode-remote-extensionpack`) includes the "Remote - Containers" functionality needed for a smooth remote session .
        - **Remote - SSH** - Work with source code in any location by opening folders on a remote machine/VM using SSH. Supports x86_64, ARMv7l (AArch32), and ARMv8l (AArch64) glibc-based Linux, Windows 10/Server (1803+), and macOS 10.14+ (Mojave) SSH hosts.
        - **Remote - Tunnels** - Work with source code in any location by opening folders on a remote machine/VM using a VS Code Tunnel (rather than SSH).
        - **Dev Containers** - Work with a separate toolchain or container based application by opening any folder mounted into or inside a container.
        - **WSL** - Get a Linux-powered development experience from the comfort of Windows by opening any folder in the Windows Subsystem for Linux.
*   **kubectl**: The Kubernetes command-line tool. You need this on your `PATH` so VS Code can communicate with your cluster . The Kubernetes extension can sometimes install it for you if it's missing .
    ```batch
    :: Install kubectl on Windows (match the WSL2 version)
    choco install kubernetes-cli --version=1.30.14
    kubectl version --client 
    MKLINK /J "%USERPROFILE%\.kube" "%HOME%\.kube"
    kubectl config view
    ```

### Inside Your Pod (Pre-requisites)

For VS Code to attach successfully, your pod needs a few things:

*   **A Running Application**: Your Go or Python app needs to be running with its debugger listening on a port.
*   **The Debugger**: For Go, this is **Delve** (`dlv`) running in headless mode. For Python, it's **debugpy**. Your Dockerfile should install and configure this.
*   **Source Code**: The source code must exist inside the pod's filesystem (e.g., at `/app`). This usually happens during the container image build. Remember, any edits you make directly to files inside the pod are **ephemeral** and will be lost if the pod restarts. You must commit and push changes to Git to save them.

### How to Connect and Edit

Once the above is set up, the connection is straightforward:

1.  In VS Code, open the **Kubernetes** view.
2.  Find your running pod.
3.  Right-click the pod and select **"Attach to VSCode"** (or a similar option).
4.  A new VS Code window will open, connected to the pod. You can now browse and edit files directly on the pod's filesystem, and the integrated terminal will run commands inside the container.

### Optional: Git Credentials via SSH Agent Forwarding

To pull or push to a private Git repo from *inside* the pod without copying your private key there, you can enable SSH agent forwarding on Windows :

1.  Open PowerShell as Administrator.
2.  Run: `Set-Service ssh-agent -StartupType Automatic`
3.  Run: `Start-Service ssh-agent`
4.  Add your key: `ssh-add $HOME/.ssh/your-private-key`

With the agent running, the pod's Git commands can use your local SSH keys securely.

---

# CDE Setup (Alt)

Setup on an Amazon EC2 instance by installing Docker on a Linux instance
and connecting via remote IDE extensions like VS Code Remote-SSH.

## Step 1: Launch the EC2 Instance

- Open the AWS Management Console and navigate to the EC2 dashboard.
- Click Launch Instance.
- Choose an AMI such as Ubuntu or Amazon Linux.
- Select an instance type (e.g., t3.medium or larger for development workloads).
- Configure your key pair (.pem) and set up a security group allowing SSH (port 22) and any specific application ports you need. [1]

## Step 2: Install Docker and Docker Compose

Connect to your instance via SSH and run the following commands (for Ubuntu):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
```

## Step 3: Configure Your Development Container

Create a project directory on the EC2 instance:

```bash
mkdir ~/my-project && cd ~/my-project
```

Add a `devcontainer.json` or `docker-compose.yml` file to define your required runtime environment, tools, and dependencies.

## Step 4: Connect via Local IDE

- Install the Remote - SSH extension in Visual Studio Code.
- Open the command palette (F1), select **Remote-SSH: Connect to Host...**, and enter your EC2 connection string (`ubuntu@your-ec2-public-ip`).
- Once connected, open your remote project folder and select **Reopen in Container** to run your full workspace inside the Docker container on the EC2 host.


```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
```


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
