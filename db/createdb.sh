#!/bin/bash

# Function definitions
#---------------------
## get floating IP address using instance name
function get_instance_floating_ip {
    this_instance_name=$1;
    inst_ip=$(openstack server list --name $this_instance_name -f json | jq --raw-output '.[].Networks' | cut -d ' ' -f2 | sed -e 's/\s+//g');
    echo $inst_ip;
}

instance_name=$1
db_name=$2

[[ $db_name == 'lims2_test' ]] && sql_dump_file=lims2_test.dump
[[ $db_name == 'lims2_local' ]] && sql_dump_file=lims2_local.dump
[[ $db_name == 'lims2_live' ]] && sql_dump_file=lims2_live.dump

## floating IP
instance_ip=$(get_instance_floating_ip $instance_name);

## create db
ssh ubuntu@$instance_ip "/usr/local/pgsql/bin/createdb $db_name"

## create user
ssh ubuntu@$instance_ip "/usr/local/pgsql/bin/createuser lims2"

## scp dump file
scp $LOCWD/db/$sql_dump_file ubuntu@$instance_ip:~/

## execute restore on the instance
#ssh ubuntu@$instance_ip "/usr/local/pgsql/bin/pg_restore --user ubuntu --host localhost -d $db_name --no-owner --role ubuntu $sql_dump_file"
ssh ubuntu@$instance_ip '/usr/local/pgsql/bin/pg_restore --user lims2 --host localhost -d lims2_test lims2_test.dump'

