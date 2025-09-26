#!/bin/bash
AIM_ID="ami-09c813fb71547fc4f"
SG_ID="sg-03c6dffbde757a30b"


for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AIM_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend"]; then
    
        IP=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-07c8acf3fa6b923fa --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        else
            IP=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-07c8acf3fa6b923fa --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
            fi
            echo "$instance: $IP"



done
    