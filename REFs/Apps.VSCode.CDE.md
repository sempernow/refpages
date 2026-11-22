# CDE (**C**loud **D**evelopment **E**nvironment) using VSCode

Containerized/cloud development workspace 

AKA 

Cloud Development Environment (CDE)

There are several Docker images built for running headless VS Code on a remote server. 
These images fall into two main categories: **community-driven open-source alternatives** (like `code-server`) and **Microsoft's official VS Code Server**.

### 🐳 Popular Headless VS Code Docker Images

| Image / Project | Key Characteristics | Best For |
| :--- | :--- | :--- |
| **`codercom/code-server`** | The most popular community-driven option. It runs a full instance of VS Code on a server, accessible via any web browser . It is MIT-licensed, making it commercially friendly and highly flexible for Docker deployments . | General purpose remote development; users who want a browser-based experience and are okay with an open-source (Code OSS) foundation. |
| **`gitpod/openvscode-server`** | An upstream, open-source project based on the same architecture used by Gitpod. It runs a server that you access via a browser . | Users who want a clean, upstream open-source server without the specific modifications of `code-server`. |
| **`lscr.io/linuxserver/openvscode-server`** | A LinuxServer.io community build of the OpenVSCode Server. It includes LinuxServer's standard features like easy user mapping (PUID/PGID) and regular updates . | Users already familiar with the LinuxServer.io ecosystem who want consistent container management. |
| **`antiantiops/vscode-browser-docker`** | Runs the **official Microsoft VS Code Server** binary. Its main advantage is retaining full compatibility with proprietary Microsoft extensions, most notably **GitHub Copilot and Copilot Chat** . | Developers who specifically need official Microsoft extensions (like Copilot) to work in a browser-based IDE. |

### 💡 Use Cases

>Browser-based CDEs do not require a local VS Code client, but CDEs that are designed for local VS Code integration absolutely do. The key is that "CDE" describes the remote environment, but it doesn't dictate how you connect to it. That choice is separate.

It's helpful to distinguish between two remote workflows:

1.  **Browser-Based Access (`code-server` style):** You open a web browser and navigate to your server's URL to access a full IDE. This is what most of the images above are designed for. It's ***completely independent of any local VS Code installation.***
2.  **Native Remote Development (Dev Containers / Tunnels):** You use your **local VS Code application** (with extensions like "Dev Containers" or "Remote - Tunnels") to connect to a remote environment. In this case, the Docker image typically contains your development tools and language runtimes, and VS Code installs a lightweight server component into it on-the-fly. Microsoft provides official guidance and templates for this workflow .

If your goal is to use your **local VS Code** to edit code running inside a Docker container, you don't necessarily need a specialized "headless VS Code" image. You would use a standard Docker image (e.g., a `python:3.11` image) and connect to it using the **Dev Containers** extension .


### How CDEs Support Both Access Methods

Platforms like **Coder** are built to support both workflows simultaneously. Coder's documentation explicitly states you can connect with either the **desktop client** or **in the browser**.

*   **For local VS Code access:** Coder provides a "VS Code Desktop" button that automatically installs a Remote extension and connects your local VS Code to the workspace. Projects like **Orchard** are also explicitly designed for "VS Code Remote SSH," meaning you use your local client to connect.
*   **For browser-only access:** The same Coder workspace can also be accessed via `code-server` running inside it, allowing you to use a browser instead.

### Why the Distinction Matters

The confusion comes from mixing up the *server* and the *client*.

*   **CDE (the server side):** This is the container, VM, or host running your code and development tools.
*   **The Client (how you edit):** This is the VS Code interface you interact with. It can be your **local VS Code app** or a **browser tab**.

A CDE platform like **Coder** or **Gitpod** gives you the remote environment. It is agnostic about your client. It can serve a browser-based IDE (like `code-server`) *and* provide the hooks for a local VS Code client to connect via SSH or a proprietary extension.


### 🔍 How to Choose

- **For a browser-based IDE** where you want the most features and commercial flexibility, **`codercom/code-server`** is the standard choice .
- If you require **GitHub Copilot or other proprietary Microsoft extensions**, the **`antiantiops/vscode-browser-docker`** image is specifically built to address that limitation .
- If you want to use your **local VS Code app** to edit inside a container, look for standard **Dev Container** images or configurations rather than a "headless VS Code" image.

---

## `vscode-server` vs `code-server`

Though similar in name, these are two different things, serving different workflows.

### 🔍 The Key Difference: Architecture, Not Just Name

*   **`vscode-server` (Microsoft's)**: This is the headless backend used by your **local VS Code client**. When you use the Remote-SSH or Dev Containers extensions, your local VS Code downloads this server onto the remote machine. It's designed to pair with the local UI you already have. You typically don't run it directly; it's managed by your local VS Code.
*   **`code-server` (Coder's)**: This is a **full, self-contained VS Code instance** that runs on a remote server and serves its **entire UI to your web browser**. It's a fork of VS Code (specifically Code OSS) that has been modified to run headlessly and be accessed over HTTP .

### 🎯 Why Both Exist

The use cases are distinct:

*   **You use `vscode-server` when** you want to keep your **local VS Code client** and all its power (like GitHub Copilot and the full Microsoft Marketplace), but point it at code on a remote host .
*   **You use `code-server` when** you want to access a development environment from a **web browser on any device** without needing a local VS Code installation at all .

### 💡 A Crucial Tradeoff with `code-server`

Because `code-server` is built on the open-source Code OSS foundation, it cannot use the official Microsoft extension marketplace. It relies on **Open VSX**, which is open but lacks some proprietary Microsoft extensions . This is exactly why you might see Docker images like `antiantiops/vscode-browser-docker`—they exist to run the **official Microsoft VS Code Server** (the same backend your local client uses) in a way that serves a browser UI, specifically to get around this limitation and retain access to Copilot and other Microsoft-exclusive tools .

So, the container image you choose depends entirely on the client you want to use: `code-server` for a browser-based experience, or a standard development image (with the `vscode-server` being injected automatically) for your local VS Code client.

It's hard to say definitively which workflow is more popular overall, because "popularity" depends on who you ask. **`vscode-server` (the native remote client) is the standard for professional developers, while `code-server` (the browser-based client) has a massive and highly visible open-source following.**

Here is how the two break down in terms of adoption:

### 📊 The Case for `code-server` (Browser-Based)

If you judge by open-source metrics, `code-server` is incredibly popular:

*   **Massive Community**: It has over **78,000 GitHub stars** and is widely considered the "definitive" way to run VS Code in a browser .
*   **Heavy Docker Usage**: The official `codercom/code-server` Docker image has recorded over **141 million downloads**, indicating it is a go-to tool for self-hosted environments .
*   **Coder's Positioning**: Coder explicitly markets `code-server` as its solution for individual developers and open-source users, distinct from its enterprise platform .

### 💻 The Case for `vscode-server` (Local Client)

While `vscode-server` doesn't have a single "star count" (it's a bundled component of VS Code), its adoption is tied to the explosive growth of the Remote Development extension pack:

*   **Professional Standard**: For developers working with Remote-SSH, Dev Containers, or WSL, this is the native workflow. It avoids the extension limitations of the browser-based alternative .
*   **The "Best of Both Worlds"**: This setup is popular because it keeps the **local UI performance** while leveraging **remote compute power**, which is a common requirement in enterprise settings .
*   **The Extension Gap**: Many developers stick with the local client because `code-server` cannot easily use Microsoft's proprietary marketplace (meaning no native Copilot, etc.), whereas `vscode-server` has full access .

### 🎯 The Bottom Line

If you define popularity by **GitHub stars and Docker pulls**, the **browser-based `code-server`** wins by a landslide. It is the dominant solution for people who want a self-hosted, accessible-from-anywhere IDE.

However, if you define popularity by **daily active usage among professional software engineers**, the **native `vscode-server` client** is likely the winner. It is the "default" workflow for anyone using VS Code's Remote features for serious development, as **it avoids the extension ecosystem compromises** of the browser fork.

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
