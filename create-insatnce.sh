#!/bin/bash

AMI=ami-09c813fb71547fc4f
SG_ID=sg-03c6dffbde757a30b
ZONE_ID=Z01730921MDPIK694OSXC
DOMAIN_NAME=abhishekdev.fun

for instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    # Wait a few seconds to allow AWS to register the instance
    sleep 5

    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
            RECORD_NAME=$instance.$DOMAIN_NAME
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
             RECORD_NAME="$DOMAIN_NAME"

    fi

    echo "$instance: $IP" 

    aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch '

 {
        "Comment": "updating the records",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
        } '
done
