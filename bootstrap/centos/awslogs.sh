#!/bin/bash

######### Configure awslogs
# Template awslogs.conf needs to be in place
# Assumes jq and awslogs have been installed

# Metadata log details 
ecs_cluster=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .Cluster')
ecs_container_instance_id=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $2}' )
macs=$(curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/ | head -1 )
vpc_id=$(curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$macs/vpc-id )
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)

# add context specific log config
sed -i -e "s/{instance_id}/$instance_id/g" /etc/awslogs/awslogs.conf
sed -i -e "s/{ecs_container_instance_id}/$ecs_container_instance_id/g" /etc/awslogs/awslogs.conf
sed -i -e "s/{ecs_cluster}/$ecs_cluster/g" /etc/awslogs/awslogs.conf
sed -i -e "s/{vpc_id}/$vpc_id/g" /etc/awslogs/awslogs.conf

service awslogs start
chkconfig awslogs on