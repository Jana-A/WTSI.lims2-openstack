#!/bin/bash

# Function definitions
# --------------------
## get an image ID from an image name
function get_image_id {
    image_name=$1;
    image_id=$(openstack image list -f json | jq ".[] | select(.Name==\"$image_name\")" | jq --raw-output '.ID' | sed -e 's/\s+//g');
    echo $image_id;
}

## build an OpenS image with Packer
function packer_build {
    json_path=$1;

    check_var=$(/usr/local/packer --version 2>&1);
    packer_var=$(echo $?);

    if (($packer_var > 0)); then
        echo 'A Packer installation was not found.';
        exit $packer_var;
    fi

    /usr/local/packer validate $json_path;
    /usr/local/packer build $json_path;
}

# Main
#------
## args
image_name=$1
packer_template_path=$2

## required argument
if [[ -z $image_name ]]; then
    echo 'Image name is required!';
    exit 1;
fi

## check if base image exists or create one
baseimage_id=$(get_image_id $image_name);

if [[ -z $baseimage_id ]]; then
    echo "OpenStack image with name $image_name was not found.";
    echo "Building the image using Packer.";
    packer_build $packer_template_path;
else
    echo "OpenStack image with ID $image_id already exists."
fi

exit 0;

