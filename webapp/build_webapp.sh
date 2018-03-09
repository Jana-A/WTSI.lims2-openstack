#!/bin/bash

## system update
sudo apt-get update

## JQ
sudo apt -y install jq

## home dir
parent_path=$HOME

for my_package in $(cat $parent_path/webapp.json | jq .sys_packages[]); do
  echo sudo apt -y install $my_package | bash
done

for perl_module in $(cat $parent_path/webapp.json | jq .perl_modules[]); do
    echo "sudo perl -MCPAN -e 'install $perl_module'" | bash
    sudo chmod -R 755 /usr/local/share/perl/5.22.1/
done;

mkdir $HOME/git_checkout/
for git_repo in $(cat $parent_path/webapp.json | jq .git_repos[]); do
    repo_name=$(echo $git_repo | cut -d'/' -f5 | cut -d'.' -f1);
    echo git clone $git_repo $HOME/git_checkout/$repo_name | bash
done
##TODO: extract git repos
echo "sudo cp -r $HOME/git_checkout/* /usr/local/share/perl/5.22.1/" | bash
echo "sudo chmod -R 755 /usr/local/share/perl/5.22.1/" | bash

