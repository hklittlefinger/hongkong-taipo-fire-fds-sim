#!/bin/bash
set -e

# Cleanup script for FDS AWS resources in a specific region

if [ $# -ne 1 ]; then
    echo "Usage: $0 <region>"
    exit 1
fi

REGION=$1

echo "Cleaning up FDS resources in $REGION..."

# Terminate instances
echo "Terminating instances..."
INSTANCES=$(aws ec2 describe-instances \
    --region "$REGION" \
    --filters "Name=tag:Name,Values=fds-*" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

if [ -n "$INSTANCES" ]; then
    for INSTANCE_ID in $INSTANCES; do
        echo "  Terminating $INSTANCE_ID..."
        aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION" > /dev/null || true
    done
    echo "  Waiting for instances to terminate..."
    for INSTANCE_ID in $INSTANCES; do
        aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$REGION" || true
    done
else
    echo "  No instances to terminate"
fi

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=fds-vpc" --query "Vpcs[*].VpcId" --output text)

if [ -z "$VPC_ID" ] || [ "$VPC_ID" == "None" ]; then
    echo "No fds-vpc found in $REGION"
    exit 0
fi

echo "Found VPC: $VPC_ID"

# Delete security groups (except default)
echo "Deleting security groups..."
SG_IDS=$(aws ec2 describe-security-groups \
    --region "$REGION" \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text)

if [ -n "$SG_IDS" ]; then
    for SG_ID in $SG_IDS; do
        echo "  Deleting security group $SG_ID..."
        aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION" || true
    done
else
    echo "  No security groups to delete"
fi

# Delete subnets
echo "Deleting subnets..."
SUBNET_IDS=$(aws ec2 describe-subnets \
    --region "$REGION" \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "Subnets[*].SubnetId" \
    --output text)

if [ -n "$SUBNET_IDS" ]; then
    for SUBNET_ID in $SUBNET_IDS; do
        echo "  Deleting subnet $SUBNET_ID..."
        aws ec2 delete-subnet --subnet-id "$SUBNET_ID" --region "$REGION" || true
    done
else
    echo "  No subnets to delete"
fi

# Delete route tables (except main)
echo "Deleting route tables..."
RT_IDS=$(aws ec2 describe-route-tables \
    --region "$REGION" \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "RouteTables[?Associations[0].Main!=\`true\`].RouteTableId" \
    --output text)

if [ -n "$RT_IDS" ]; then
    for RT_ID in $RT_IDS; do
        echo "  Deleting route table $RT_ID..."
        aws ec2 delete-route-table --route-table-id "$RT_ID" --region "$REGION" || true
    done
else
    echo "  No route tables to delete"
fi

# Delete VPC endpoints
echo "Deleting VPC endpoints..."
ENDPOINT_IDS=$(aws ec2 describe-vpc-endpoints \
    --region "$REGION" \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "VpcEndpoints[*].VpcEndpointId" \
    --output text)

if [ -n "$ENDPOINT_IDS" ]; then
    for ENDPOINT_ID in $ENDPOINT_IDS; do
        echo "  Deleting VPC endpoint $ENDPOINT_ID..."
        aws ec2 delete-vpc-endpoints --vpc-endpoint-ids "$ENDPOINT_ID" --region "$REGION" || true
    done
else
    echo "  No VPC endpoints to delete"
fi

# Detach and delete internet gateways
echo "Detaching and deleting internet gateways..."
IGW_IDS=$(aws ec2 describe-internet-gateways \
    --region "$REGION" \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query "InternetGateways[*].InternetGatewayId" \
    --output text)

if [ -n "$IGW_IDS" ]; then
    for IGW_ID in $IGW_IDS; do
        echo "  Detaching internet gateway $IGW_ID..."
        aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION" || true
        echo "  Deleting internet gateway $IGW_ID..."
        aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --region "$REGION" || true
    done
else
    echo "  No internet gateways to delete"
fi

# Delete VPC
echo "Deleting VPC $VPC_ID..."
aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" || true

# Delete key pair
echo "Deleting key pair..."
aws ec2 delete-key-pair --key-name "$(basename ~/.ssh/fds-key-pair 2>/dev/null || echo 'fds-key-pair')" --region "$REGION" 2>/dev/null || echo "  No key pair to delete"

echo "Cleanup complete for $REGION"
