
#!/bin/bash

<<<<<<< HEAD
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01bc7ebe005fb1cb2" # replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z032558618100M4EJX8X4" # replace with your ZONE ID
DOMAIN_NAME="daws84s.site" # replace with your domain

#for instance in ${INSTANCES[@]}
for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01bc7ebe005fb1cb2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$DOMAIN_NAME"
=======
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
>>>>>>> 0adeb97d21de464be28fbf63dc1cdff54dbe3c66
    fi

    echo "$instance IP address: $IP"

    aws route53 change-resource-record-sets \
<<<<<<< HEAD
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
=======
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
>>>>>>> 0adeb97d21de464be28fbf63dc1cdff54dbe3c66
            }]
        }"
done
