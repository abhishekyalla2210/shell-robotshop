#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SEC_GROUP="sg-03c6dffbde757a30b"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SEC_GROUP--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query 'Instances[0].InstanceId' --output text)
    
    if [ $instance -ne "frontend" ]; then 
        IP=$( aws ec2 describe-instances --instanc5d7ae8fe377f --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
         IP=$(aws ec2 describe-instances --instanc5d7ae8fe377f --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
         fi
         echo "$instance: $IP"
done




