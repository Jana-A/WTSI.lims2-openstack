#!/bin/bash

# ------------------------
# lims2 database functions
# ------------------------
function lims2-opens {
    VERSION=0.1
    printf "\nA set of commands to build a LIMS2 environment on OpenStack.\n"
    printf "\nVersion: $VERSION\n"
    printf "\nUsage:\n\n"
    echo "- DB -"
    printf ". lims2-db-create-image: Create a base image for a LIMS2 database server.\n"
    printf ". lims2-db-launch-instance: Launch a database server accepting connections at port 5432 (PGSQL port).\n"
    printf ". lims2-db-configure: Create a LIMS2 database on a running database instance.\n"
    printf "\n"
    echo "- WebApp -"
    printf ". lims2-webapp-create-image: Create a base image having LIMS2 WebApp specifications .\n"
    printf ". lims2-webapp-launch-instance: Launch an instance from the LIMS2-spec base image and open port 3000.\n"
    printf ". lims2-webapp-configure: Configure a LIMS2-spec instance to act as Gitlab runner or a HTGT3 server.\n\n"
}

function lims2-db-create-image {
    if [[ $1 == '-h' ]]; then
        echo "- lims2-opens -"
        printf "\nUsage:\n\n"
        printf "lims2-db-create-image\t<image name>\n\n"
    else
        image_name=$1
        if [[ -z $image_name ]]; then
            echo "Image name needed.";
            lims2-db-create-image '-h';
        else
            $LOCWD/common/check_and_create_opens_image.sh $image_name $PACKER_TEMPLATES/db/pgsql_image.json
            openstack image set --property name=$image_name pgsql
        fi
    fi
}

function lims2-db-launch-instance {
    if [[ $1 == '-h' ]]; then
        echo "- lims2-opens -"
        printf "\nUsage:\n\n"
        printf "lims2-db-launch-instance\t<base image>\t<instance name>\n\n"
    else
        baseimage_name=$1
        instance_name=$2
        $LOCWD/common/launch_opens_instance.sh $baseimage_name $instance_name
        sleep 60;
        $LOCWD/db/build_lims2_db.sh $instance_name
    fi
}

function lims2-db-configure {
    if [[ $1 == '-h' ]]; then
        echo "- lims2-opens -"
        printf "\nUsage:\n\n"
        printf "lims2-db-configure\t<instance name>\t<database name>\n"
        printf "database name:\t<lims2_test>, <lims2_local> or <lims2_live>\n\n"
    else
        instance_name=$1
        db_name=$2
        $LOCWD/db/createdb.sh $instance_name $db_name
    fi
}

# ----------------------
# lims2 webapp functions
# ----------------------
function lims2-webapp-create-image {
    if [[ $1 == '-h' ]]; then
        echo "- lims2-opens -"
        printf "\nUsage:\n\n"
        printf "lims2-webapp-create-image\t<image name>\n\n"
    else
        image_name=$1
        if [[ -z $image_name ]]; then
            echo "Image name needed.";
            lims2-webapp-create-image '-h';
        else
            $LOCWD/common/check_and_create_opens_image.sh $image_name $PACKER_TEMPLATES/webapp/webapp_image.json
            openstack image set --property name=$image_name webapp
        fi
    fi
}

function lims2-webapp-launch-instance {
    if [[ $1 == '-h' ]]; then
        echo "- lims2-opens -"
        printf "\nUsage:\n\n"
        printf "lims2-webapp-launch-instance\t<base image>\t<instance name>\n\n"
    else
        baseimage_name=$1
        instance_name=$2
        $LOCWD/common/launch_opens_instance.sh $baseimage_name $instance_name
    fi
}

function lims2-webapp-configure {
    ## configure to listen on a port
    ## copy gitlab file
    if [[ $1 == '-h' ]]; then
        echo "- lims2-opens -"
        printf "\nUsage:\n\n"
        printf "lims2-webapp-configure\t<instance name>\t<option>\n\n"
        printf "option:\t<ci> or <htgt3>\n\n"
    else
        instance_name=$1
        option=$2
        $LOCWD/webapp/configure_webapp.sh $instance_name $option
    fi
}

