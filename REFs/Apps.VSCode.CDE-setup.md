# CDE Setup

Containerized cloud development workspace 
AKA 
Cloud Development Environment (CDE)

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


---

