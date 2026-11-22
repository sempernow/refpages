# Elastic Container Service (ECS) (Docker)  

Elastic Container Service; Docker => EC2;    
Elastic Container Registry (ECR); handles ELB;    
Run/manage containers across a cluster of EC2 instances.  
DevGuide  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html  
CLI Ref   https://docs.aws.amazon.com/cli/latest/reference/ecs/index.html  

- Workflow   
    CodeCommit (Git) => Docker CLI => ECR => ECS => EC2 Instance(s)  
## [Two Launch Types](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html) 
- __Fargate__   
Host a cluster on a serverless infra managed by ECS  
Register Task Definition, and Fargate launches it. 
    - Bind Mounts 
    - Fargate Task Storage (10GB; ephemeral)
- __EC2__  
Host tasks on a cluster of EC2 instances
    - [Bind Mounts](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/bind-mounts.html) 
    - [Docker Volumes](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-volumes.html) (EBS:`/var/lib/docker/volumes`)

    - Task Networking @ `awsvpc` Network Mode  
        - So ECS tasks get same network properties as EC2 instances. 

## [Creating a Cluster with EC2 Task Using AWS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-ec2.html) [Tutorial]

## "Deploying Docker to AWS [2017-09-27] [Lynda]"  

- ECS/ECR (Elastic Container Registry; Repo)     
ECS > Repositories > Create new repo   
View Push Commands > (button; lists relevant `aws` & `docker` CLI commands)  

- Login to AWS  

    ```bash
    # Login to AWS  
    aws ecr get-login --no-include-email --region 'us-east-1'
    # Returns login command w/ passord-key-string  ...
    docker login -u AWS -p eyjwXYl4765elwrj8selrle77jq ... https://${AWS_ECR_REPO}.dkr.ecr.us-east-1.amazonaws.com
    # ... copy/paste it back into terminal
    ```
- Push to AWS  

    ```bash
    # Push Image to AWS
    docker push "${AWS_ECR_REPO}.dkr.ecr.us-east-1.amazonaws.com/${NAME}:${TAG}"
    ```  

- Create Task   
    ECS > Task Definitions  

- Run  
    ECS > Clusters >   
    Task Definition:  
    Number of tasks: (replicas/instances)  
    Run (button)   

## ECS > Launch Wizard (Fargate) ... FAILed  

## EKS (Kubernetes)  
Managed Kubernetes; service that handles scaling, upgrades and all of the management of the Kubernetes service and its clusters.  https://aws.amazon.com/eks/  

## FarGate 
Managed service for running Docker containers; handles all the underlying infrastructure; like EC2, but "instances" are containers, not VMs.  

