#!/bin/bash

AMI=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0c5e9ef09eaede486
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
   echo "Instance is: $i"
   if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
     then
        INSTANCE_TYPE="t3.small"
     else
        INSTANCE_TYPE="t2.micro"
    fi

done

aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0c5e9ef09eaede486