# the password change 

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

# ----------------------------------------------
# 