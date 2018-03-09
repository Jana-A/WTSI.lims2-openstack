#!/bin/bash

## dependencies
check_var=$(jq --version 2>&1);
jq_var=$(echo $?);
if (($jq_var > 0)); then
    echo '! A JQ installation was not found.';
    exit $jq_var;
fi
echo "-> Found JQ installation version: $check_var";

check_var=$(openstack --version 2>&1);
openstack_var=$(echo $?);
if (($openstack_var > 0)); then
    echo '! An OpenStack CLI installation was not found.';
    exit $openstack_var;
fi
echo "-> Found OpenStack installation version: $check_var";

## setup
cwd=$(pwd)
config=$cwd/setup/config.json

openrc_path=$(cat $config | jq --raw-output .openrc);
packer_templates=$(cat $config | jq --raw-output .packer_templates);

echo "-> Setting LOCWD to $cwd";
export LOCWD=$cwd

echo "-> Setting OPENRC to $openrc_path";
export OPENRC=$openrc_path

echo "-> Setting PACKER_TEMPLATES to $packer_templates";
export PACKER_TEMPLATES=$packer_templates

echo "-> Sourcing $openrc_path";
source $openrc_path

echo "-> Sourcing functions.sh";
source $cwd/bin/functions.sh

