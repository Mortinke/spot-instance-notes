#!/bin/bash

AUTO_SCALING_GROUP_NAME=$1

echo -e "region\t\tinstance-type\tspot-price\trequest-price\tdiff-total\tdiff-percentage"
while read i a p m; do s=$(aws ec2 describe-spot-price-history --instance-types $i --availability-zone $a --product-descriptions "Linux/UNIX (Amazon VPC)" --start-time $(date +%FT%TZ) --end-time $(date +%FT%TZ) --output text); echo -e $s $m | awk '{print $2, "\011", $3, "\011", $5, "\011", $7, "\011", ($7-$5), "\011", ($7-$5)/$7*100}'; done < <(for sir in $(aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=$AUTO_SCALING_GROUP_NAME" "Name=instance-state-name,Values=running" "Name=instance-lifecycle,Values=spot" --query 'Reservations[*].Instances[*].[SpotInstanceRequestId]' --output text); do aws ec2 describe-spot-instance-requests --spot-instance-request-ids $sir --query 'SpotInstanceRequests[*].[LaunchSpecification.InstanceType, LaunchedAvailabilityZone, ProductDescription, SpotPrice]' --output text; done)
