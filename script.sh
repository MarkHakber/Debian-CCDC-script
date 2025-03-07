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

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!"
    exit 1
fi

echo "🔄 Checking environment on MWCCDC Debian machine..."

# 🟢 1️⃣ Check if SSH service exists before stopping
if systemctl list-units --type=service | grep -q ssh; then
    systemctl stop ssh
    if systemctl is-active --quiet ssh; then
        echo "❌ Failed to stop SSH!"
    else
        echo "✅ SSH service has been stopped."
    fi
else
    echo "⚠️ SSH service not found. Skipping."
fi

# 🟢 2️⃣ Check if BIND exists before backup
if [[ -d "/etc/bind" ]]; then
    BACKUP_DIR="/root/backit"
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DEST="$BACKUP_DIR/bind_backup_$TIMESTAMP"

    mkdir -p "$BACKUP_DIR"
    cp -r /etc/bind "$BACKUP_DEST"

    if [[ -d "$BACKUP_DEST" ]]; then
        echo "✅ BIND backup successful: $BACKUP_DEST"
    else
        echo "❌ BIND backup failed!"
    fi
else
    echo "⚠️ BIND directory (/etc/bind) not found. Skipping backup."
fi

# 🟢 3️⃣ Add login notification with `wall`
if command -v wall &> /dev/null; then
    echo 'wall "$(id -un) logged in from $(echo $SSH_CLIENT | awk '"'"'{print $1}'"'"')" ' >> ~/.bashrc
    echo 'wall "$(id -un) logged in from $(echo $SSH_CLIENT | awk '"'"'{print $1}'"'"')" ' | sudo tee /etc/profile.d/login_wall.sh > /dev/null
    sudo chmod +x /etc/profile.d/login_wall.sh

    # Verify `wall` works
    if grep -q "wall \"\$(id -un) logged in from" ~/.bashrc; then
        echo "✅ Login notification added to .bashrc."
    else
        echo "❌ Failed to add login notification to .bashrc!"
    fi
else
    echo "⚠️ 'wall' command not found. Skipping login notification."
fi

# Bruteforce remove and reinstall UFW
echo "🚨 Forcefully reinstalling UFW..."
apt-get remove --purge -y ufw
apt-get update
apt-get install -y ufw

# Verify UFW installation
if command -v ufw &> /dev/null; then
    echo "✅ UFW successfully installed."
else
    echo "❌ UFW installation failed. Exiting..."
    exit 1
fi

echo "🔒 Configuring UFW firewall..."

# Reset firewall rules to prevent conflicts
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow necessary services (adjust as needed)
ufw allow 53/udp      # DNS
ufw allow 53/tcp      # DNS over TCP
ufw allow 123/udp     # NTP (Network Time Protocol)
ufw allow 22/tcp      # SSH (Only if needed, otherwise keep blocked)

# Allow IPv6 versions as well
ufw allow proto udp from any to any port 53
ufw allow proto tcp from any to any port 53
ufw allow proto udp from any to any port 123
ufw allow proto tcp from any to any port 22

# Enable UFW
ufw --force enable

echo "✅ UFW firewall installation & configuration complete!"

# Install Fail2Ban if not installed
if ! command -v fail2ban-client &> /dev/null; then
    echo "📦 Installing Fail2Ban..."
    apt update && apt install -y fail2ban
else
    echo "✅ Fail2Ban is already installed."
fi

# Enable Fail2Ban service
systemctl enable fail2ban
systemctl start fail2ban

# Create a jail.local configuration file
echo "🔧 Configuring Fail2Ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Apply SSH brute-force protection settings
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
bantime = 1h
findtime = 10m
maxretry = 3
logpath = /var/log/auth.log
logtarget = /var/log/fail2ban.log
EOF

# Restart Fail2Ban to apply changes
systemctl restart fail2ban

# Verify Fail2Ban status
fail2ban-client status sshd

echo "✅ Fail2Ban installation & configuration complete!"

# Install Lynis if not installed
if ! command -v lynis &> /dev/null; then
    echo "📦 Installing Lynis..."
    apt update && apt install -y lynis
else
    echo "✅ Lynis is already installed."
fi

# Run an initial Lynis audit
echo "🔍 Running initial Lynis security audit..."
lynis audit system --quick

# Store Lynis report
REPORT_FILE="/var/log/lynis_audit.log"
lynis audit system --quiet | tee "$REPORT_FILE"

# Verify Lynis installation
echo "✅ Lynis installation complete!"
echo "📊 Report saved at: $REPORT_FILE"

echo "🎉 Script execution complete!"



