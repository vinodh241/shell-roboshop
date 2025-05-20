#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"  # Amazon Machine Image ID
SG_ID="sg-052fc2c712d4ff7066"   # Security Group ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "frontend")
ZONE_ID="Z07082243VUB84KU714AG"
DOMAIN_NAME="vinodh.site"

for instance in "${INSTANCES[@]}"
do
    echo "Launching instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.small \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${instance}}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "Waiting for instance $INSTANCE_ID to be in running state..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

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

    echo "$instance IP address: $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Creating or Updating a record set for $instance\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$instance.$DOMAIN_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 1,
                    \"ResourceRecords\": [{ \"Value\": \"$IP\" }]
                }
            }]
        }"
done
