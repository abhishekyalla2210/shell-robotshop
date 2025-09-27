#!/bin/bash

USER_ID=$(id -u)

AMI="ami-09c813fb71547fc4f"
SG_ID="sg-03c6dffbde757a30b"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=mongodb}]" --query 'Instances[0].InstanceId' --output text)


if [$instance != "frontend"]; then
    IP=$(aws ec describe-instances --instance-ids $INSTANCE_ID --query "Reservation[0].Instances[0].PrivateIpAddress" --output text )
else
     IP=$(aws ec describe-instances --instance-ids $INSTANCE_ID --query "Reservation[0].Instances[0].PublicIpAddress" --output text )

fi
    echo "$instance: $IP"
done



