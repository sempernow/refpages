#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Create servers @ generic :: retrofit existing machine into docker-machine.
# https://docs.docker.com/machine/drivers/generic/ 
# -----------------------------------------------------------------------------
exit
########################################################
# docker-machine create ... @ MINGW or PowerShell ONLY
########################################################

# NOTE: Generic driver DOES NOT SUPPORT start|stop|rm 
# ***********************************************
# ***  Add AWS per Generic : Use scriptL ec2  ***
# ***********************************************

mp='aa' # Machines' namespace
ssh_private_key=~/.ssh/swarm-aws.pem
#... Download private key of the AWS "key pair" (.pem); download only the private key, 
# and then generate the public key (naming it *.pem.pub). Store both @ ~/.ssh/, 
# as both are required by generic driver.
# Access:  ssh -i ~/.ssh/swarm-aws.pem ubuntu@${ip}
ip=3.85.135.114
ssh_user='ubuntu' # Default is root 

echo "=== Create manager machines (idempotent)"
for i in 3 2 1; do 
    echo "=== @ '${mp}$i'"
    [[ $( docker-machine ls -q | grep ${mp}$i ) ]] && {
        echo "Machine '${mp}$i' already exists."
    } || \
        docker-machine create \
            --driver 'generic' \
            --generic-ip-address=$ip \
            --generic-ssh-user=$ssh_user \
            --generic-ssh-key=$ssh_private_key \
            ${mp}$i 
done

# List IPs of all running instances 
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[KeyName,PublicIpAddress,Placement.AvailabilityZone, InstanceId,SecurityGroups[0].GroupId]' \
    --output text | awk '{print $2}'

# List selected details of all running instances 
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[Tags[*].Value,KeyName,PublicIpAddress,Placement.AvailabilityZone, InstanceId,SecurityGroups[0].GroupId]'

# Add EXISTING instance (VM) to docker-machine
vm=ac1
ssh_user='ubuntu' # Default is root 
ssh_private_key=~/.ssh/swarm-aws.pem
ip=52.90.218.120
docker-machine create \
    --driver 'generic' \
    --generic-ip-address=$ip \
    --generic-ssh-user=$ssh_user \
    --generic-ssh-key $ssh_private_key \
    $vm

# Get ...
export n=3        # Number of nodes in (namespaced) swarm
export mp='h'     # aa|dn|h; machine(s) prefix
# Swarm Leader:
export sl=${mp}1  # hardcode if UNCONFIGURED terminal, else ...
export sl=$(docker node ls | grep 'Leader' | awk '{print $3}') 
#... if already CONFIGURED (per `docker-machine env $sl`)

export ip=$(docker-machine ip $sl) # PUBLIC IP (We want private @ DO)  3.92.60.21
export user=$(docker-machine inspect $sl --format={{.Driver.SSHUser}})
export key=$(docker-machine inspect $sl --format={{.Driver.SSHKeyPath}})
export port=$(docker-machine inspect $sl --format={{.Driver.SSHPort}})
# vm: i1, sl: i1, ip: 3.88.249.184, user: ubuntu, key: C:\Users\X1\.docker\machine\machines\i1\id_rsa, port: 22
echo "n: $n, mp: $mp, sl: $sl, ip: $ip, user: $user, key: $key, port: $port"

# Add user access to docker engine @ each node (IF NOT ALREADY):
for i in 3 2 1; do 
do 
    echo "=== Add user '$user' access to Docker Engine @ '${mp}$i'"
    docker-machine ssh ${mp}$i "sudo usermod -aG docker $user"
done

exit 

# AWS CLI ... 

# List Public IP Address(es) 
aws ec2 describe-instances \
    --instance-id $iid \
    --query 'Reservations[].Instances[].PublicIpAddress' 

# List details 
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,State:State.Name,Name:KeyName,AZ:Placement.AvailabilityZone,Arch:Architecture,AMI:ImageId,Type:InstanceType,VPC:VpcId,SubNet:SubnetId,SG:NetworkInterfaces[0].Groups[*],Storage:RootDeviceType}' | jq .

# VM Commands 
aws ec2 start-instances --instance-ids ...
aws ec2 stop-instances --instance-ids ...
aws ec2 reboot-instances --instance-ids ...
aws ec2 terminate-instances --instance-ids ...

# -----------------------------------------------------------------------------
# Mod 1. :: Associate the EIP with Swarm Leader's primary ENI (eth0)  *** PREFERRED  ***
    # 1. Get ID of EC2's primary ENI (Elastic Network Interface; eth0):
        export eniPrimary=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${sl}" \
                    --query 'Reservations[*].Instances[*].NetworkInterfaces[*].[NetworkInterfaceId]' \
                    --output text) #... eni-09350fdcbd0d867b7 
    # 2. Get AllocationID of the EIP (Elastic IP) address of RUNNING INSTANCE:
        export eipAlloc=$(aws ec2 describe-addresses --query 'Addresses[].[AllocationId]' --output text)
        #... eipalloc-0e97db21e288ebdd5 
    # 3. Make the association ... 
    aws ec2 associate-address \
        --allocation-id  $eipAlloc \
        --network-interface-id $eniPrimary \
        --allow-reassociation  #> eipassoc-0efc4768343b7e0dd

# List the machines; swarm leader CERT is now INVALID:
docker-machine ls #... certs are bound to IP address(es) to which they were issued.

# -----------------------------------------------------------------------------
# Regenerate certificates (for the new IP address; EIP)

m='managers-'
for i in 3 2 1; do 
    echo "Regenerate Certificates @ node '${mp}$i'"
    rm ~/.docker/machine/machines/${mp}$i/{ca,cert,key,server,server-key}.pem -f
    docker-machine regenerate-certs ${mp}$i --force
done


# Validate certs/comms:
docker-machine ls

# Show the public IP address:
ip=$(docker-machine ip $sl)  
echo $ip  #... should be the EIP: 54.80.28.150

# -----------------------------------------------------------------------------
# Mod 2. :: Associate Route53 DNS with EIP (kvpairs.com, www.kvpairs.com)


# -----------------------------------------------------------------------------
# Mod 3. :: Attach (secondary) ENI (eth1) to EC2  

    # FAILs if AMI is not Amazon Linux; requires network config ...
    # REF:            https://aws.amazon.com/premiumsupport/knowledge-center/ec2-ubuntu-secondary-network-interface/ 
    # AWS UserGuide:  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#scenarios-enis 
    # See:            PRJ.EC2.Attach.ENI

    # Attach ENI (as second NIC, e.g., eth1) to EC2 instance (WHILE RUNNING)
    aws ec2 attach-network-interface \
        --network-interface-id 'eni-090416e04c96d0207' \
        --instance-id 'i-06d08b380751ef22c' \
        --device-index 1
    # Then associate EIP with ENI; then set Route53 DNS 'A' record to EIP.
    # Whatever ENI setup (Subnet, SG, ...) travels with it; ENI is portable (attach/detach), 
    # unlike an EC2 instance's Primary Network Interface (eth0) 

    # Describe ...
    aws ec2 describe-addresses \
         --query 'Addresses[].[{EC2:InstanceId,EIP:{IP:PublicIp,AllocID:AllocationId,AssocID:AssociationId}}]'

    # Associate EIP with ENI
    eipAlloc=$(aws ec2 describe-addresses --query 'Addresses[].[AllocationId]' --output text)
    aws ec2 associate-address \
        --allocation-id  $eipAlloc \
        --network-interface-id 'eni-090416e04c96d0207' \
        --private-ip-address 10.0.1.64 \
        --region 'us-east-1'

    ip=$(docker-machine ip $sl) #... PUBLIC IP, but NOT EIP


# Mod 4. UPSERT Route53 with Public IPs on (re)start

{
    "Comment": "UPSERT per CLI",
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "kvpairs.com",
            "Type": "A",
            "TTL": 500,
            "ResourceRecords": [{
                "Value": "34.226.224.113"
            }]
        }
    }]
}


# docker-machine create ... installs TinyCore (`boot2docker.iso`); 
# TinyCore distro has package manager: tce-load 
# Download and install
tce-load -w -i socat.tcz tor.tcz nginx.tcz tzdata.tcz

# Index of available TinyCore packages:
# http://distro.ibiblio.org/tinycorelinux/10.x/x86/tcz/
