#!/bin/bash

# Function definitions
#---------------------
## get floating IP address using instance name
function get_instance_floating_ip {
    this_instance_name=$1;
    inst_ip=$(openstack server list --name $this_instance_name -f json | jq --raw-output '.[].Networks' | cut -d ' ' -f2 | sed -e 's/\s+//g');
    echo $inst_ip;
}

# Main
#------
## args
this_instance_name=$1
option=$2

## required argument
if [[ -z $this_instance_name ]]; then
    echo 'Instance name is required!';
    exit 1;
fi

## floating IP
this_instance_ip=$(get_instance_floating_ip $this_instance_name);

## add webapp security group
openstack server add security group $this_instance_name webapp

## open webapp port
ssh ubuntu@$this_instance_ip 'sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT'
ssh ubuntu@$this_instance_ip ' echo source /opt/t87/global/scripts/bash_utils.sh >> /home/ubuntu/.bashrc'

## configure as gitlab runner
if [[ $option == 'ci' ]]; then
    scp $LOCWD/webapp/config.toml ubuntu@$this_instance_ip:~/
    scp $LOCWD/webapp/gitlab_settings.sh ubuntu@$this_instance_ip:~/
    ssh ubuntu@$this_instance_ip 'bash gitlab_settings.sh'
elif [[ $option == 'htgt3' ]]; then
    ## configure as running HTGT3 API
    echo 'htgt3'
fi


