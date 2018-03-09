#!/bin/bash

# Function definitions
#---------------------
## get an instance ID from an instance name
function get_instance_id {
    instance_name=$1;
    instance_id=$(openstack server list -f json | jq ".[] | select(.Name==\"$instance_name\")" | jq --raw-output '.ID' | sed -e 's/\s+//g');
    echo $instance_id;
}

## get an image ID from an image name
function get_image_id {
    image_name=$1;
    image_id=$(openstack image list -f json | jq ".[] | select(.Name==\"$image_name\")" | jq --raw-output '.ID' | sed -e 's/\s+//g');
    echo $image_id;
}

## get free floating IP address
function get_free_floating_ip {
    free_floating_ip=$(openstack ip floating list -f json | jq "[.[] | select(.Port==null)][0]" | jq --raw-output '."Floating IP Address"' | sed -e 's/\s+//g');
    echo $free_floating_ip;
}

## get floating IP address using instance name
function get_instance_floating_ip {
    instance_name=$1;
    inst_ip=$(openstack server list --name $instance_name -f json | jq --raw-output '.[].Networks' | cut -d ' ' -f2 | sed -e 's/\s+//g');
    echo $inst_ip;
}

## spin up an OpenS server from an image
function launch_opens_instance {
    image_id=$1;
    instance_name=$2;

    openstack server create \
    --flavor m1.small \
    --image $image_id \
    --key-name autoimage_pub \
    --security-group ssh-inbound \
    --nic=net-id=ff286d86-7863-4020-985d-75a484497045 \
    $instance_name
}

## check if image name exists in your tenant or create a new one
function opens_base_image_check {
    image_id=$1;
    json_file=$2;
    grep_image=$(openstack image list | grep $image_id);
    if [[ -z $grep_image ]]; then
        echo "OpenStack image with ID $image_id was not found.";
        echo "Will build the image using Packer.";
        packer_build $json_file;
    else
        echo "OpenStack image with ID $image_id exists. Proceeding."
    fi
}

## check if instance name exists in your tenant or create a new one
function opens_instance_check_and_launch {
    instance_name=$1;
    image_id=$2;

    grep_instance=$(openstack server list --name $instance_name);

    if [[ -z $grep_instance ]]; then
        echo "Launching an instance from base image ID $image_id";

        ## extract free floating IP address
        free_floating_ip=$(get_free_floating_ip);

        ## create a floating IP address
        if [[ -z $free_floating_ip ]]; then
            nova floating-ip-create;
            free_floating_ip=$(get_free_floating_ip);
        fi

        ## spin up an openstack instance
        launch_opens_instance $image_id $instance_name;

        ## add a floating IP to an instance
        instance_id=$(get_instance_id $instance_name);

        ## replace w/ 'openstack ip floating create'
        nova add-floating-ip $instance_id $free_floating_ip;

        openstack server add security group $instance_name default
        openstack server add security group $instance_name web
        openstack server add security group $instance_name ssh-inbound
    else
        echo "Instance $instance_name already exists.";
    fi
}

# Main
#------
## args
base_image_name=$1
instance_name=$2

## required argument
if [[ -z $base_image_name ]]; then
    echo 'Image name is required!';
    exit 1;
fi

## required argument
if [[ -z $instance_name ]]; then
    echo 'Instance name is required!';
    exit 1;
fi

## check if base image exists
baseimage_id=$(get_image_id $base_image_name);

if [[ -z $baseimage_id ]]; then
    echo "Can not find base image with name $base_image_name. You need to create this image or supply an existing image.";
else
    opens_instance_check_and_launch $instance_name $baseimage_id
fi

exit 0;

