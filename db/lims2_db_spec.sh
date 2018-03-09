#!/bin/bash


source ~/.bashrc

## initialise the db cluster as ubuntu
sudo chown -R ubuntu:ubuntu /usr/local
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data

echo "host    all             all             0.0.0.0/0            trust" >> /usr/local/pgsql/data/pg_hba.conf
echo listen_addresses = \'*\' >> /usr/local/pgsql/data/postgresql.conf

## start the db server
/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data > logfile 2>&1 &

## open psql port
sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT

## create db
#createdb lims2_test

