#!/bin/bash

AMI="ami-09c813fb71547fc4f"
SG_ID="sg-03c6dffbde757a30b"
OUTPUT_FILE="instances-info.txt"

# Clear old file if it exists
mkdir -p $OUTPUT_FILE

for instance in "$@";
 do
   

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    sleep 10

    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
    fi

    echo "$instance: $IP (Instance ID: $INSTANCE_ID)" | tee -a "$OUTPUT_FILE"
done

echo " All instance info saved to $OUTPUT_FILE"
