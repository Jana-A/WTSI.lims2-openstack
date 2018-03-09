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

## required argument
if [[ -z $this_instance_name ]]; then
    echo 'Instance name is required!';
    exit 1;
fi

## floating IP
this_instance_ip=$(get_instance_floating_ip $this_instance_name);
openstack server add security group $this_instance_name psql

## building lims2 db spec
scp $LOCWD/db/lims2_db_spec.sh ubuntu@$this_instance_ip:~/
ssh ubuntu@$this_instance_ip 'bash lims2_db_spec.sh'

