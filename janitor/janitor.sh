#!/bin/bash

source ./constants.sh

MODE="dry-run"
DAYS=$DEFAULT_DAYS

# check arguments
for arg in "$@"
do
  if [ "$arg" == "--delete" ]; then
    MODE="delete"
  fi
done

echo "Running Cost Janitor in $MODE mode"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TOTAL_ORPHANS=0
TOTAL_COST=0

# create empty files
echo "" > report.json
echo "" > report.md

# start report.json
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

# -------------------------------
# Check unattached EBS volumes
# -------------------------------

VOLUMES=$(awslocal ec2 describe-volumes \
  --filters Name=status,Values=available \
  --query "Volumes[*].VolumeId" \
  --output text)

for vol in $VOLUMES
do
  echo "Found unattached volume: $vol"

  TOTAL_ORPHANS=$((TOTAL_ORPHANS + 1))
  TOTAL_COST=$((TOTAL_COST + EBS_COST_PER_MONTH))

  if [ "$FIRST" = false ]; then
    echo "," >> report.json
  fi

  FIRST=false

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

  if [ "$MODE" == "delete" ]; then
    awslocal ec2 delete-volume --volume-id "$vol"
    echo "Deleted $vol"
  fi
done

# -------------------------------
# Check unassociated Elastic IPs
# -------------------------------

EIPS=$(awslocal ec2 describe-addresses \
  --query "Addresses[?AssociationId==null].AllocationId" \
  --output text)

for eip in $EIPS
do
  echo "Found unused Elastic IP: $eip"

  TOTAL_ORPHANS=$((TOTAL_ORPHANS + 1))
  TOTAL_COST=$((TOTAL_COST + EIP_COST_PER_MONTH))

  echo "," >> report.json

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
    awslocal ec2 release-address --allocation-id "$eip"
    echo "Released $eip"
  fi
done

# -------------------------------
# Finish report
# -------------------------------

cat <<EOF >> report.json
  ]
}
EOF

# update summary values
sed -i "s/\"total_orphans\": 0/\"total_orphans\": $TOTAL_ORPHANS/" report.json
sed -i "s/\"estimated_monthly_waste_usd\": 0/\"estimated_monthly_waste_usd\": $TOTAL_COST/" report.json

echo "" >> report.md
echo "Total Orphans: $TOTAL_ORPHANS" >> report.md
echo "Estimated Monthly Waste: \$$TOTAL_COST" >> report.md

# fail in dry-run mode
if [ "$MODE" == "dry-run" ] && [ $TOTAL_ORPHANS -gt 0 ]; then
  exit 1
fi

exit 0