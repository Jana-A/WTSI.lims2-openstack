#!/bin/bash

## system update
sudo apt update

## postgres dependencies
sudo apt -y install make
sudo apt -y install gcc
sudo apt -y install build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev

## postgres from source
tar xf postgresql-9.1.24.tar
cd postgresql-9.1.24
./configure
make
make check
sudo make install

## add /usr/local/pgsql/bin to $PATH
echo 'export PATH=$PATH:/usr/local/pgsql/bin/' >> ~/.bashrc

## install pgsql
##TODO specify version
#sudo apt install -y postgresql postgresql-contrib

