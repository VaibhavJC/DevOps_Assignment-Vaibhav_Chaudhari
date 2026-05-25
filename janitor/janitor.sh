#!/bin/bash

source ./constants.sh

# AWS / LocalStack Configuration

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

AWS_LOCAL="aws --endpoint-url=http://localhost:4566"

MODE="dry-run"
DAYS=$DEFAULT_DAYS

# Parse Arguments

for arg in "$@"
do
  if [ "$arg" == "--delete" ]; then
    MODE="delete"
  fi
done

echo "======================================"
echo "Running Cost Janitor in $MODE mode"
echo "======================================"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TOTAL_ORPHANS=0
TOTAL_COST=0

# Initialize Reports

> report.json
> report.md

cat <<EOF > report.json
{
  "scan_timestamp": "$TIMESTAMP",
  "account_id": "000000000000",
  "region": "us-east-1",
  "summary": {
    "total_orphans": 0,
    "estimated_monthly_waste_usd": 0
  },
  "findings": [
EOF

FIRST=true

echo "# Cost Janitor Summary" >> report.md
echo "" >> report.md

# Helper Function

add_comma() {
  if [ "$FIRST" = false ]; then
    echo "," >> report.json
  fi
  FIRST=false
}

# 1. Unattached EBS Volumes

echo ""
echo "Scanning unattached EBS volumes..."

VOLUMES=$($AWS_LOCAL ec2 describe-volumes \
  --filters Name=status,Values=available \
  --query "Volumes[*].VolumeId" \
  --output text)

for vol in $VOLUMES
do
  echo "Found unattached volume: $vol"

  TOTAL_ORPHANS=$((TOTAL_ORPHANS + 1))
  TOTAL_COST=$((TOTAL_COST + EBS_COST_PER_MONTH))

  add_comma

  cat <<EOF >> report.json
{
  "resource_id": "$vol",
  "resource_type": "ebs_volume",
  "reason": "unattached",
  "age_days": 0,
  "estimated_monthly_cost_usd": $EBS_COST_PER_MONTH,
  "tags": {},
  "suggested_action": "delete",
  "safe_to_auto_delete": true
}
EOF

  echo "- Unattached EBS Volume: $vol" >> report.md

  PROTECTED=$($AWS_LOCAL ec2 describe-volumes \
    --volume-ids "$vol" \
    --query "Volumes[0].Tags[?Key=='Protected'].Value" \
    --output text)

  if [ "$MODE" == "delete" ] && [ "$PROTECTED" != "true" ]; then
    $AWS_LOCAL ec2 delete-volume --volume-id "$vol"
    echo "Deleted $vol"
  fi
done

# 2. Stopped EC2 Instances

echo ""
echo "Scanning stopped EC2 instances..."

INSTANCES=$($AWS_LOCAL ec2 describe-instances \
  --filters Name=instance-state-name,Values=stopped \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

for instance in $INSTANCES
do
  echo "Found stopped instance: $instance"

  TOTAL_ORPHANS=$((TOTAL_ORPHANS + 1))
  TOTAL_COST=$((TOTAL_COST + EC2_COST_PER_MONTH))

  add_comma

  cat <<EOF >> report.json
{
  "resource_id": "$instance",
  "resource_type": "ec2_instance",
  "reason": "stopped_instance",
  "age_days": $DAYS,
  "estimated_monthly_cost_usd": $EC2_COST_PER_MONTH,
  "tags": {},
  "suggested_action": "terminate",
  "safe_to_auto_delete": true
}
EOF

  echo "- Stopped EC2 Instance: $instance" >> report.md

  PROTECTED=$($AWS_LOCAL ec2 describe-instances \
    --instance-ids "$instance" \
    --query "Reservations[0].Instances[0].Tags[?Key=='Protected'].Value" \
    --output text)

  if [ "$MODE" == "delete" ] && [ "$PROTECTED" != "true" ]; then
    $AWS_LOCAL ec2 terminate-instances --instance-ids "$instance"
    echo "Terminated $instance"
  fi
done

# 3. Unused Elastic IPs

echo ""
echo "Scanning unused Elastic IPs..."

EIPS=$($AWS_LOCAL ec2 describe-addresses \
  --query "Addresses[?AssociationId==null].AllocationId" \
  --output text)

for eip in $EIPS
do
  echo "Found unused Elastic IP: $eip"

  TOTAL_ORPHANS=$((TOTAL_ORPHANS + 1))
  TOTAL_COST=$((TOTAL_COST + EIP_COST_PER_MONTH))

  add_comma

  cat <<EOF >> report.json
{
  "resource_id": "$eip",
  "resource_type": "elastic_ip",
  "reason": "not_attached",
  "age_days": 0,
  "estimated_monthly_cost_usd": $EIP_COST_PER_MONTH,
  "tags": {},
  "suggested_action": "release",
  "safe_to_auto_delete": true
}
EOF

  echo "- Unused Elastic IP: $eip" >> report.md

  if [ "$MODE" == "delete" ]; then
    $AWS_LOCAL ec2 release-address --allocation-id "$eip"
    echo "Released $eip"
  fi
done

# 4. Missing Required Tags

echo ""
echo "Scanning instances for missing tags..."

ALL_INSTANCES=$($AWS_LOCAL ec2 describe-instances \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

for instance in $ALL_INSTANCES
do
  TAGS=$($AWS_LOCAL ec2 describe-instances \
    --instance-ids "$instance" \
    --query "Reservations[0].Instances[0].Tags[*].Key" \
    --output text)

  MISSING=""

  for tag in "${REQUIRED_TAGS[@]}"
  do
    echo "$TAGS" | grep -q "$tag"

    if [ $? -ne 0 ]; then
      MISSING="$MISSING $tag"
    fi
  done

  if [ ! -z "$MISSING" ]; then

    echo "Instance $instance missing tags:$MISSING"

    TOTAL_ORPHANS=$((TOTAL_ORPHANS + 1))

    add_comma

    cat <<EOF >> report.json
{
  "resource_id": "$instance",
  "resource_type": "ec2_instance",
  "reason": "missing_tags",
  "age_days": 0,
  "estimated_monthly_cost_usd": 0,
  "tags": {
    "missing": "$MISSING"
  },
  "suggested_action": "add_tags",
  "safe_to_auto_delete": false
}
EOF

    echo "- Missing Tags on Instance: $instance -> $MISSING" >> report.md
  fi
done

# Finish JSON

cat <<EOF >> report.json
  ]
}
EOF

# Update Summary

sed -i "s/\"total_orphans\": 0/\"total_orphans\": $TOTAL_ORPHANS/" report.json

sed -i "s/\"estimated_monthly_waste_usd\": 0/\"estimated_monthly_waste_usd\": $TOTAL_COST/" report.json

echo "" >> report.md
echo "Total Orphans: $TOTAL_ORPHANS" >> report.md
echo "Estimated Monthly Waste: \$$TOTAL_COST" >> report.md

# Exit Behavior

if [ "$MODE" == "dry-run" ] && [ $TOTAL_ORPHANS -gt 0 ]; then
  echo ""
  echo "Orphaned resources detected."
  exit 1
fi

echo ""
echo "Scan completed successfully."

exit 0