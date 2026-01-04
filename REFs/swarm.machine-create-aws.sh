#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Add AWS EC2 instances (VMs) to docker-machine
# -----------------------------------------------------------------------------

# *************************
# ***  Use script: ec2  ***
# *************************

# -----------------------------------------------------------------------------
# AWS CLI :: EC2 :: START|STOP|REBOOT|TERMINATE

# STATE 
state='running' # running # stopped

# ACTION on ALL :: stop|start|reboot|terminate|... ALL per IDs filtered per state
action='stop' 
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=${state}" \
    --query 'Reservations[*].Instances[*].[InstanceId]' \
    --output text | sed 's/\n//g' \
    | xargs aws ec2 ${action}-instances --instance-ids

# ACTION per ID 
iid='i-006fe920766c49ff5'
aws ec2 start-instances     --instance-ids "$iid"
aws ec2 stop-instances      --instance-ids "$iid"
aws ec2 reboot-instances    --instance-ids "$iid"
aws ec2 terminate-instances --instance-ids "$iid"  

# -----------------------------------------------------------------------------
# AWS CLI :: EC2 :: LIST

mp='a'
list_suffix=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone]' --output text \
    | sed 's/us-east-//')
list=$(printf "${mp}%s " $list_suffix) # a1a a1b a1c
#... but can't match IP to names; only to AZ

# IP per AZ
az=us-east-1a
ip=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, PublicIpAddress]' \
    --output text | grep -- "$az" | awk '{print $2}' | head -n1)
# IP per Name
vm='a1b'
ip=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].{Tags:Tags[?Key=='Name']|[0].Value,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}" \
    --output text | grep -- "$vm" | awk '{print $3}' | head -n1)

# FILTER per TAGs :: key:val
--filters "Name=tag:Name,Values=a1a"
--filters "Name=tag:$key,Values=$val" #... CSV list of values, but UNORDERED.

# per ANY filter (string) against query: IP, ID, AZ, Type, State
filter='stopped'
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].{Type:InstanceType,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' \
    --output text | grep -- $filter

# (Re)set
state='stopped' # running # stopped

# List ALL by AZ, ID, IP, Type, State (TABLE)
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=${state}" \
    --query 'Reservations[*].Instances[*].{Type:InstanceType,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' \
    --output table

# List ALL by AZ, ID, IP, Type, State (TABLE) :: FILTER by Tag
key='Name'
val='a1b'
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=${state}" \
    --filters "Name=tag:$key,Values=$val" \
    --query 'Reservations[*].Instances[*].{Type:InstanceType,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' 
    --output table

# List ALL by AZ, ID, IP, Type, State, Tags[Name]
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=${state}" \
    --query "Reservations[*].Instances[*].{Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}" \
    --output table | sed 1,2d
    # +------------+-----------------------+-----------------+-------+----------+------------+
    # |     AZ     |          ID           |       IP        | Name  |  State   |   Type     |
    # +------------+-----------------------+-----------------+-------+----------+------------+
    # |  us-east-1a|  i-0a6e9ac6cfb8cd8ea  |  54.234.90.253  |  a1a  |  running |  t3.micro  |
    # |  us-east-1b|  i-072ad98848742e098  |  34.203.199.19  |  a1b  |  running |  t3.micro  |
    # |  us-east-1c|  i-022f64744500d8808  |  52.203.203.157 |  a1c  |  running |  t3.micro  |
    # +------------+-----------------------+-----------------+-------+----------+------------+

aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=${state}" \
    --query 'Reservations[*].Instances[*].{Tags:Tags[*]}' \
    --output text

# List ALL by AZ, ID, IP
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=${state}" \
    --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, InstanceId, PublicIpAddress]' \
    --output text 

# List ALL Describe subset info; all VMs 
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,State:State.Name,Name:KeyName,AZ:Placement.AvailabilityZone,Arch:Architecture,AMI:ImageId,Type:InstanceType,VPC:VpcId,SubNet:SubnetId,SG:NetworkInterfaces[0].Groups[*],Storage:RootDeviceType}' | jq .[]

# List ALL to JSON file
aws ec2 describe-instances --filters "Name=instance-state-name,Values=${state}" \
    > aws.ec2.describe-instances.running.json

# ------------------------------------------
# RESET Route53 IPs of the associated domain 
./auto-update-route53-ips.sh
# Validate 
domain=kvpairs.com
ping $domain

# -----------------------------------------------------------------------------
# docker-machine :: ADD EXISTING instance(s) (VM) per 'generic' driver

# Filter per tag (WIP)
tag='true'
hasTag="$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[Tags[*].Value]' \
    --output text | grep "$tag")"

user='ubuntu'   # set per Terraform; default user is root 
key=~/.ssh/swarm-aws.pem
for x in $list; do 
    # Find public IP of (first) VM in AZ '*-1${x}' 
    ip=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, PublicIpAddress]' \
        --output text | grep -- "-1${x}" | awk '{print $2}' | head -n1)

    [[ $ip ]] && echo "=== ${mp}$x" \
        && docker-machine create \
            --driver 'generic' \
            --generic-ip-address=$ip \
            --generic-ssh-user=$user \
            --generic-ssh-key $key \
            ${mp}$x
            #... https://docs.docker.com/machine/drivers/generic/ 
done

# -----------------------------------------------------------------------------
# docker-machine :: ADD NEW instance(s) (VM) per 'amazonec2' driver

list='a1a a1b a1c' # vendor/az
region='us-east-1' 
ami='ami-0156cf6a58f94dfea' # ubuntu-bionic-18.04-amd64-minimal-20200917
user='ubuntu' # CANNOT 'root'; no choice over user; must be ami_user 
key=~/.ssh/swarm-aws.pem 
# Access:  ssh -i ~/.ssh/swarm-aws.pem ubuntu@${ip}  # SUCCESS
aa1='subnet-0da057dec1145eb14'
ab1='subnet-061b9e48c1e5ea27d'
ac1='subnet-0fd994025df538406'
echo "=== Create manager machines (idempotent)"
for vm in $list
do 
    echo "=== @ '$vm'"
    [[ $( docker-machine ls -q | grep $vm ) ]] && {
        echo "Machine '$vm' already exists."
    } || \
        docker-machine create \
            --driver 'amazonec2' \
            --amazonec2-ami "$ami" \
            --amazonec2-instance-type='t2.micro' \
            --amazonec2-vpc-id='vpc-0ae8e1beddd77fe65' \
            --amazonec2-subnet-id="$aa1" \
            --amazonec2-tags="Name,${vm},Role,manager" \
            --amazonec2-region="$region" \
            --amazonec2-zone="${vm:1:1}" \
            --amazonec2-ssh-user="$user" \
            --amazonec2-ssh-keypath=$key \
            --amazonec2-retries=1 \
            --amazonec2-userdata='./userdata.install-docker.sh' \
            --amazonec2-open-port=80 \
            $vm 
            # https://docs.docker.com/machine/drivers/aws/ 
            
            # --amazonec2-subnet-id="${!vm}" \ #... FAILing @ seperate AZs

            # --amazonec2-security-group='open' \
            # FAILing at CSV groups
            # --amazonec2-security-group='WebDMZ,swarm-managers,swarm-workers' \
            # --amazonec2-security-group='swarm-workers' \
            # --amazonec2-security-group='swarm-managers' \

            # These options cause hang on create @ "Waiting for SSH ..."
            # --amazonec2-private-address-only=false \
            # --amazonec2-use-private-address=true \
            #... yet can set @ swarm init (@ LEADER_IP) ???
done

# -----------------------------------------------------------------------------
# Configure terminal to swarm leader's Docker server

export sl='h1'    # hardcode @ UNCONFIGURED.
docker-machine env $sl
# If NOT @ cross-vendor, then can reset for Control Plane per Private IP
#export DOCKER_HOST="tcp://${LEADER_IP}:2376" 
eval $(docker-machine env $sl)

export list="$(dm ls | grep Running | awk '{printf "%s ", $1}')"
export sl=$(docker node ls | grep 'Leader' | awk '{print $3}') 
#... IF CONFIGURED ALREADY per `docker-machine env $_VM`
echo "sl: $sl, list: $list"

export ip=$(docker-machine ip $sl) # PUBLIC IP 
export user=$(docker-machine inspect $sl --format={{.Driver.SSHUser}})
export key=$(docker-machine inspect $sl --format={{.Driver.SSHKeyPath}})
export port=$(docker-machine inspect $sl --format={{.Driver.SSHPort}})
# vm: i1, sl: i1, ip: 3.88.249.184, user: ubuntu, key: C:\Users\X1\.docker\machine\machines\i1\id_rsa, port: 22
echo "sl: $sl, ip: $ip, user: $user, key: $key, port: $port"

# Add user access to docker engine @ each node:
for vm in $list
do 
    echo "=== Add user '$user' access to Docker Engine @ '$vm'"
    docker-machine ssh $vm "sudo usermod -aG docker $user"
done

exit 

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

# If swarm comms is per public IP, then certs may be invalid with each machine restart
machines='a3,a2,a1' 

for vm in $list
do 
    echo "Regenerate Certificates @ node '$vm'"
    rm ~/.docker/machine/machines/$vm/{ca,cert,key,server,server-key}.pem -f
    docker-machine regenerate-certs $vm --force
done

# Validate certs/comms:
docker-machine ls

# Show the public IP address:
ip=$(docker-machine ip $sl)  
echo $ip  #... should be the EIP: 54.80.28.150

# -----------------------------------------------------------------------------
# Mod 2. :: Associate Route53 DNS with EIP (kvpairs.com, www.kvpairs.com)

curl kvpairs.com
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> dae81be8e186<br/><b>Visits:</b> 2
curl kvpairs.com
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> 3c54fa678148<br/><b>Visits:</b> 3
curl kvpairs.com
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> 87c1cbf1f2fe<br/><b>Visits:</b> 4

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

