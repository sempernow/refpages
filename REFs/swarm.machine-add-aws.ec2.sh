#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  AWS EC2 :: ADD (to Docker machine)|RESET (IPs & CERTs)|START|STOP|LIST 
# 
#  ARGs: add|reset|start|stop|list
# -----------------------------------------------------------------------------

ec2_all(){ # List ALL instances (AZ, ID, IP, and State)
    aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' --output table  # text
}

ec2_running(){ # List ALL RUNNING instances (AZ, ID, IP, and State)
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' \
        --output table 
}
export ec2_all ec2_running 

# Start|Stop 
[[ "$1" == 'start' ]] && state=stopped
[[ "$1" == 'stop' ]] && state=running
[[ $state != '' ]] && {
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=${state}" \
        --query 'Reservations[*].Instances[*].[InstanceId]' \
        --output text | sed 's/\n//g' | xargs aws ec2 ${1}-instances --instance-ids
}

# Reset IP & Regenerate Certs 
[[ "$1" == 'reset' ]] && {
    printf "%s\n\n" 'Reset IP & Regenerate Certs'
    for x in a b c; do
        az="1${x}";vm="a${az}"
        file=~/.docker/machine/machines/${vm}/config.json
        ip=$(ec2_running | grep $az | awk '{print $5}')
        [[ ( $ip != '' ) && -r $file ]] && {
            echo "=== '$vm'"
            sed -i "/IPAddress/c\        \"IPAddress\": \"${ip}\"," "$file" 
            rm ~/.docker/machine/machines/$vm/{ca,cert,key,server,server-key}.pem -f
            docker-machine regenerate-certs $vm --force
        }
    done
}

# List
[[ "$1" == 'list' ]] && ec2_all

# Add 
[[ "$1" == 'add' ]] && {
    printf "%s\n\n" 'Add AWS EC2 instances to docker-manager tool:'
    ssh_user='ubuntu' # set per Terraform; default user is root 
    ssh_private_key=~/.ssh/swarm-aws.pem
    for x in a b c; do
        az=1${x}
        ip=$(ec2_running | grep $az | awk '{print $5}')
        [[ $ip != '' ]] && {
            docker-machine create \
                --driver 'generic' \
                --generic-ip-address=$ip \
                --generic-ssh-user=$ssh_user \
                --generic-ssh-key $ssh_private_key \
                a${az}
        }
    done
    docker-machine ls 
}

exit

# List :: IPs of all running instances, per `jq` tool
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' | jq .[] | jq -r .[].IP
