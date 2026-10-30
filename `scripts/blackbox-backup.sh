```bash
#!/bin/bash
# BlackBox CloudOps Automated Backup Script

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/tmp/blackbox_backup_$BACKUP_DATE.tar.gz"
S3_DEST="s3://blackbox-logs-backup-6751/backups/"

# Compress Nginx configuration and web root into a single archive
tar -czf "$BACKUP_FILE" /etc/nginx /var/www/html

# Upload the archive to S3
aws s3 cp "$BACKUP_FILE" "$S3_DEST"

# Cleanup local temporary backup file
rm -f "$BACKUP_FILE"

echo "BlackBox Backup completed successfully at $(date)"
