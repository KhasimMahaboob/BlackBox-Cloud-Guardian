# 🛡️ BlackBox Cloud Guardian

### AWS Cloud Operations | Site Reliability Engineering | Automated Incident Management | Disaster Recovery

**BlackBox Cloud Guardian** is an enterprise-inspired AWS Cloud Operations and SRE project designed to demonstrate infrastructure monitoring, incident detection, automated backups, troubleshooting, and disaster recovery using core AWS services and Linux automation.

The project simulates common infrastructure failures and demonstrates how cloud engineers can detect issues, investigate their causes, perform remediation, and verify service recovery.

Rather than simply deploying cloud resources, this project focuses on understanding how different AWS services work together to maintain infrastructure reliability, security, and operational visibility.

---

## 🎯 Project Objectives

* Build a secure AWS network using a custom VPC.
* Deploy and manage an Ubuntu-based EC2 web server.
* Implement persistent storage using Amazon EBS.
* Store automated infrastructure backups in Amazon S3.
* Secure AWS resource access using IAM roles and policies.
* Maintain application incident records using Amazon RDS MySQL.
* Monitor infrastructure health using Amazon CloudWatch.
* Automate recurring operational tasks using Python, Bash, and Linux Cron.
* Simulate infrastructure failures and demonstrate recovery procedures.

---

## 🏗️ Architecture Overview

```text
                       INTERNET
                           |
                           |
                    Internet Gateway
                           |
                           |
              +--------------------------+
              |       BLACKBOX VPC       |
              |       10.0.0.0/16        |
              |                          |
              |    PUBLIC SUBNET         |
              |     10.0.1.0/24          |
              |                          |
              |    +----------------+    |
              |    |   Amazon EC2   |    |
              |    |  Ubuntu Linux  |    |
              |    |     Nginx      |    |
              |    |  Python        |    |
              |    |   Watchdog     |    |
              |    +-------+--------+    |
              |            |             |
              |            |             |
              |       +----v-----+       |
              |       |   EBS    |       |
              |       | Persistent|      |
              |       |  Storage |       |
              |       +----------+       |
              |            |             |
              |            |             |
              |     PRIVATE SUBNETS      |
              |     10.0.2.0/24          |
              |     10.0.3.0/24          |
              |     10.0.4.0/24          |
              |                          |
              |     +-------------+      |
              |     | Amazon RDS  |      |
              |     |   MySQL     |      |
              |     |  Port 3306  |      |
              |     +-------------+      |
              +--------------------------+
                           |
                           |
                    Amazon S3
                  Backup Storage

       Supporting AWS Services:

       IAM  |  CloudWatch  |  Systems Manager
```

**Note:** The diagram represents the logical architecture. The additional private subnet is part of the database subnet group. The EC2 instance and RDS database communicate through private VPC networking.

---

# 1. AWS Infrastructure Components

## 1.1 Amazon VPC – Network Isolation

**Resource:** `blackbox-vpc`

**CIDR:** `10.0.0.0/16`

Created a custom Virtual Private Cloud to provide an isolated networking environment for the project.

### Configurations

* Created a custom VPC.
* Configured public and private subnets.
* Attached an Internet Gateway.
* Configured separate public and private route tables.
* Associated subnets with appropriate route tables.
* Configured security groups to control network traffic.
* Distributed database subnet group resources across two Availability Zones.

### Subnet Allocation

| Subnet               | CIDR        | Availability Zone | Purpose               |
| -------------------- | ----------- | ----------------- | --------------------- |
| Public Subnet        | 10.0.1.0/24 | us-east-1a        | Web server            |
| Private Subnet A     | 10.0.2.0/24 | us-east-1a        | Database networking   |
| Private Subnet B     | 10.0.3.0/24 | us-east-1a        | Database subnet group |
| Private Subnet B-AZ2 | 10.0.4.0/24 | us-east-1b        | Database subnet group |

### Learning Outcomes

* Understanding CIDR addressing.
* Public versus private subnets.
* Internet Gateway functionality.
* Route table associations.
* Security group configuration.
* Availability Zone concepts.

---

## 1.2 Amazon EC2 – Compute Infrastructure

**Instance:** `blackbox-web-01`

**Instance Type:** `t3.micro`

**Operating System:** Ubuntu Linux

Amazon EC2 hosts the web server and operational scripts.

### Configurations

* Launched Ubuntu EC2 inside the custom VPC.
* Installed Nginx web server.
* Configured the monitoring dashboard.
* Installed Python dependencies.
* Configured AWS Systems Manager Session Manager.
* Attached an IAM instance profile.
* Enabled IMDSv2.
* Configured security group restrictions.

### Linux Administration

Practiced:

* Linux directory management.
* File permissions.
* Service management using `systemctl`.
* System resource inspection.
* Process monitoring.
* Log investigation.
* Shell scripting.
* Cron scheduling.

### Important Commands

```bash
uptime
df -h
free -h
systemctl status nginx
systemctl is-active amazon-ssm-agent
curl -I http://localhost
journalctl -p err
```

---

## 1.3 Amazon EBS – Persistent Block Storage

**Mount Point:** `/mnt/blackbox-data`

An additional EBS volume was attached to the EC2 instance to provide persistent block storage.

### Configurations

* Created and attached an EBS volume.
* Identified the NVMe block device.
* Created an ext4 filesystem.
* Mounted the volume.
* Identified its filesystem UUID.
* Configured automatic mounting using `/etc/fstab`.
* Used the `nofail` option to improve boot resilience.

### Verification

```bash
lsblk
sudo blkid
df -h
findmnt /mnt/blackbox-data
```

### Disaster Simulation

Simulated storage exhaustion using a dummy file:

```bash
fallocate -l 10G /mnt/blackbox-data/stress_test.img
```

After testing, removed the temporary file:

```bash
sudo rm -f /mnt/blackbox-data/stress_test.img
```

**Learning Outcomes:**

* Block storage management.
* Filesystem creation.
* UUID-based mounting.
* Persistent storage configuration.
* Disk capacity monitoring.
* Storage troubleshooting.

---

## 1.4 Amazon RDS – Managed MySQL Database

**Database:** `blackbox-db`

**Engine:** MySQL

**Database Port:** 3306

Amazon RDS provides managed relational database storage for incident records.

### Configurations

* Deployed MySQL using Amazon RDS.
* Created a DB subnet group.
* Configured private database accessibility.
* Associated the RDS security group.
* Restricted inbound MySQL traffic to the application security group.
* Created the `blackbox_db` database.
* Created an `incidents` table.

### Incident Table

| Column           | Purpose                    |
| ---------------- | -------------------------- |
| incident_id      | Unique incident identifier |
| title            | Incident title             |
| severity         | Incident severity          |
| status           | Active or Resolved         |
| timestamp        | Incident creation time     |
| resolution_notes | Remediation information    |

### Connectivity Verification

Tested database connectivity from the EC2 environment.

```bash
nc -zv blackbox-db.c6fi4u2ecr4y.us-east-1.rds.amazonaws.com 3306
```

### Learning Outcomes

* Managed database deployment.
* Database subnet groups.
* Private database connectivity.
* Security group referencing.
* SQL queries.
* Database troubleshooting.
* Application-to-database integration.

---

# 2. AWS Security & Identity Management

## 2.1 AWS IAM – Role-Based Access Control

IAM controls who can access AWS resources and what actions they can perform.

### IAM Groups

The project uses separate access categories:

| Group     | Responsibility                           |
| --------- | ---------------------------------------- |
| Admin     | Infrastructure administration            |
| CloudOps  | Infrastructure monitoring and operations |
| Developer | Application development and deployment   |
| Intern    | Restricted read-only observation         |

### EC2 Instance Role

**Role:** `blackbox-ec2-role`

Attached to the EC2 instance through an instance profile.

Used for secure AWS service access without embedding long-lived access keys in application code.

### Security Practices

* IAM roles for EC2.
* Least-privilege permission design.
* Separation of user permissions.
* No hardcoded AWS access keys.
* Restricted database credentials.
* Private database access.

**Learning Outcome:** Understanding how identity and permissions control access to cloud infrastructure.

---

# 3. Amazon S3 – Automated Backup Pipeline

**Bucket:** `blackbox-logs-backup-6751`

Amazon S3 acts as the remote backup destination.

### Configurations

* Created a private S3 bucket.
* Enabled bucket versioning.
* Enabled Block Public Access.
* Configured EC2 IAM permissions for backup uploads.
* Created an automated Bash backup script.

### Backup Script

**Location:**

`/usr/local/bin/blackbox-backup.sh`

### Backup Workflow

1. Collect important Nginx configuration files.
2. Collect website files.
3. Compress them into a timestamped `.tar.gz` archive.
4. Upload the archive to S3.
5. Record execution information in the backup log.
6. Remove temporary local archives when appropriate.

### S3 Destination

```text
s3://blackbox-logs-backup-6751/backups/
```

### Verification

```bash
sudo /usr/local/bin/blackbox-backup.sh

sudo tail -n 30 /var/log/blackbox-backup.log
```

Verify uploaded objects in the S3 console.

---

# 4. Automation & Monitoring

## 4.1 Python Health Watchdog

**Script:** `disk_watchdog.py`

Developed a Python-based monitoring script to inspect the available storage on the EBS mount point.

### Responsibilities

* Monitor disk utilization.
* Identify storage threshold violations.
* Detect abnormal conditions.
* Record incidents in the MySQL database.
* Maintain incident status information.

### Incident Workflow

```text
EBS Storage
     |
     v
Python Watchdog
     |
     v
Threshold Detection
     |
     v
Amazon RDS MySQL
     |
     v
Incident Dashboard
     |
     v
Active Incident
```

---

## 4.2 Linux Cron – Task Scheduling

Automated recurring operational tasks using Linux Cron.

### Backup Schedule

```cron
0 0 * * * /usr/local/bin/blackbox-backup.sh
```

Runs the backup script daily at midnight according to the server's configured timezone.

### Watchdog Schedule

```cron
*/5 * * * * /usr/bin/python3 /path/to/disk_watchdog.py
```

Runs the watchdog every five minutes.

*The actual script path and configured schedules should match the deployed environment.*

### Verification

```bash
sudo crontab -l
```

---

## 4.3 Amazon CloudWatch – Infrastructure Monitoring

Configured CloudWatch monitoring for infrastructure health.

### Monitoring Areas

* EC2 CPU utilization.
* RDS CPU utilization.
* Database connections.
* Infrastructure performance metrics.
* CloudWatch alarm states.

### Alarm Configuration

**Alarm:** `blackbox-db-high-cpu`

**Metric:** `CPUUtilization`

**Threshold:** 80%

**Evaluation Period:** 5 minutes.

The alarm is intended to identify unusually high database CPU utilization.

### SNS Integration

Configured an SNS topic:

`blackbox-alerts`

Subscribed an administrative email endpoint and connected alarm state notifications to the topic.

---

# 5. Incident Simulation & Disaster Recovery

One of the main objectives of BlackBox Cloud Guardian is to understand how infrastructure behaves during failures.

The project includes three operational incident scenarios.

## Incident 1: EBS Storage Saturation

**Severity:** Critical

### Simulation

Created a dummy file to consume available EBS storage.

### Detection

The Python watchdog checks disk utilization and records qualifying incidents in RDS.

### Remediation

Removed the temporary stress file and verified storage availability.

---

## Incident 2: Nginx Web Server Outage

**Severity:** High

### Simulation

Stopped the Nginx service during controlled testing.

### Detection

Inspected service status and investigated server logs.

### Remediation

```bash
sudo systemctl start nginx
```

### Verification

```bash
sudo systemctl is-active nginx

curl -I http://localhost
```

Expected result:

```text
HTTP/1.1 200 OK
```

---

## Incident 3: S3 Backup Permission Denial

**Severity:** High

### Simulation

Tested backup failure caused by an incorrect or insufficient IAM permission configuration.

### Investigation

* Inspected IAM role permissions.
* Checked backup script configuration.
* Reviewed backup execution logs.
* Verified the S3 destination.

### Remediation

Corrected the required permissions and tested the backup pipeline again.

---

# 6. Incident Management & SQL Remediation

The dashboard retrieves incident information from the RDS MySQL database.

Incidents move through two main states:

* Active
* Resolved

### Incident Resolution Query

```sql
UPDATE incidents
SET status = 'Resolved',
    resolution_notes = CONCAT(
        resolution_notes,
        ' [Resolved via automated SRE remediation sweep.]'
    )
WHERE status = 'Active';
```

### Verification Query

```sql
SELECT incident_id,
       title,
       severity,
       status
FROM incidents
ORDER BY incident_id DESC;
```

The dashboard reflects database updates after refreshing its incident information.

---

# 7. Operations & Troubleshooting Runbook

| Problem                     | Investigation                           | Recovery                                 |
| --------------------------- | --------------------------------------- | ---------------------------------------- |
| Website unavailable         | Check EC2 and Nginx                     | Restart Nginx if necessary               |
| High disk utilization       | Check `df -h`                           | Investigate and remove unnecessary files |
| Database connection failure | Check endpoint and security groups      | Correct connectivity configuration       |
| S3 upload failure           | Inspect IAM permissions and backup logs | Correct permissions and retry            |
| High database CPU           | Inspect CloudWatch metrics              | Investigate database workload            |
| Watchdog failure            | Inspect Cron and system logs            | Correct script or scheduling issue       |

---


# 8. Key Skills Demonstrated

* AWS Infrastructure Deployment
* VPC Networking
* Subnet Isolation and Routing
* EC2 Administration
* Ubuntu Linux Administration
* EBS Storage Management
* RDS MySQL
* S3 Backup Automation
* IAM and RBAC
* AWS Systems Manager
* CloudWatch Monitoring
* Python Automation
* Bash Scripting
* Linux Cron
* SQL Database Management
* Incident Response
* Disaster Recovery
* Infrastructure Troubleshooting

---

# 9. Future Improvements

Potential future enhancements:

* Infrastructure as Code using Terraform.
* Automated infrastructure provisioning.
* CloudWatch Logs integration.
* VPC Flow Logs for network traffic investigation.
* S3 lifecycle policies.
* Automated backup restoration testing.
* Improved incident notification workflows.
* Application health checks and automated recovery.

---

## Project Philosophy

**Detect. Investigate. Remediate. Verify. Recover.**

BlackBox Cloud Guardian demonstrates the practical workflow of a Cloud Operations Engineer or Site Reliability Engineer when dealing with infrastructure failures.

The objective is not simply to deploy AWS resources, but to understand their interactions, identify failures, troubleshoot problems, and maintain reliable cloud infrastructure.

---

## Disclaimer

This is an educational AWS hands-on project built in a personal cloud environment. It demonstrates selected cloud operations, security, monitoring, and disaster-recovery practices. It is not a certified production-ready system.
