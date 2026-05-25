# Multi-cloud Reality

To support AWS, GCP, and Azure in the future, the Cost Janitor should follow a modular architecture similar to how Terraform modules work with different tfvars files for different environments. The main Janitor engine would remain common and reusable, while separate provider modules such as aws_scanner.sh, gcp_scanner.sh, and azure_scanner.sh would contain cloud-specific commands and authentication logic. The core engine would only handle common tasks such as scanning flow, report generation, cost calculation, and delete rules. Each cloud provider module would return data in a common JSON format so the main engine can process it uniformly. This approach avoids rewriting the full Janitor logic when adding a new cloud provider and makes the project easier to maintain and scale in future multi-cloud environments.

---

# Permissions

**Dry-run Mode Permissions

In --dry-run mode, the Janitor only needs read-only permissions to inspect resources, tags, and resource states. It should not have permission to modify or delete anything.

**Delete Mode Permissions

In --delete mode, the Janitor additionally requires permissions to:

Delete unattached EBS volumes
Release unused Elastic IPs
Terminate stopped EC2 instances
Read resource tags before deletion

**Minimal IAM Policy for Read-only Mode
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyJanitorPermissions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:DescribeAddresses",
        "ec2:DescribeTags",
        "s3:ListBucket",
        "s3:GetBucketTagging"
      ],
      "Resource": "*"
    }
  ]
}

---

# Safety Net

**Failure Mode 1 — Deleting a stopped EC2 instance still required by a team

A stopped EC2 instance may belong to a staging environment or a team temporarily not using it. Automatically deleting it could remove important application data or configurations.

**Guardrail:
Skip deletion for resources tagged with Protected=true and require resources to remain stopped for a configurable number of days before considering deletion.

**Failure Mode 2 — Deleting unattached EBS volumes containing backups or snapshots

Some unattached EBS volumes may still contain important backup data or recovery information even if not attached to an instance.

**Guardrail:
Enable delete operations only after dry-run validation, add approval workflows for production accounts, and verify required backup tags before deletion.

---

# Observability

To configure observability, I would use Amazon CloudWatch or Grafana/Prometheus dashboards so the FinOps and DevOps teams can continuously monitor cloud waste and the overall health of the Cost Janitor automation. Below are the metrics that would help determine whether the Janitor is working correctly:

To detect sudden increases in orphan resources, I would create a metric named total_orphan_resources with an alert threshold of >10 resources. The metric source would be report.json.
To identify high cloud waste, I would create a metric named estimated_monthly_waste_usd with an alert threshold of >$100.
To detect failed automation runs, I would create a metric named janitor_scan_status with an alert triggered when the scan status becomes Failed.
To monitor tagging compliance, I would create a metric named missing_required_tags_count with an alert threshold of >5 resources missing required tags.