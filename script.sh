# the password change 

# ================================================

#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!" 
    exit 1
fi

# Set the new password
NEW_PASSWORD="Orhon9b@22hunter"

# Change the root password
echo "root:$NEW_PASSWORD" | chpasswd
echo "✅ Root password changed."

# Check if sysadmin user exists and change its password
if id "sysadmin" &>/dev/null; then
    echo "sysadmin:$NEW_PASSWORD" | chpasswd
    echo "✅ Sysadmin password changed."
else
    echo "⚠️ User 'sysadmin' does not exist. Skipping."
fi

echo "🎉 Password change complete!"

# ================================================
# ================================================
# ================================================

# bind local backup

# ================================================

# Define backup directory
BACKUP_DIR="/root/backit"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DEST="$BACKUP_DIR/bind_backup_$TIMESTAMP"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup the /etc/bind directory
cp -r /etc/bind "$BACKUP_DEST"

# Verify backup success
if [[ -d "$BACKUP_DEST" ]]; then
    echo "✅ Backup successful: $BACKUP_DEST"
else
    echo "❌ Backup failed!"
    exit 1
fi

# ================================================
# ================================================
# ================================================

