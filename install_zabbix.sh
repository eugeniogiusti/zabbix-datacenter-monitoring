#!/bin/bash

# Path to MySQL configuration
CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"

# Step 1: Installing Zabbix repository
echo "Step 1: Installing Zabbix repository..."
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.4+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest_6.4+ubuntu22.04_all.deb
apt update

# Step 2: Required packages
echo "Step 2: Installing packages..."
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Step 3: Installing and Enabling MySQL
echo "Step 3: Installing MySQL..."
apt install -y mysql-server
systemctl start mysql
systemctl enable mysql
systemctl status mysql

# Step 4: mysql_secure_installation
echo "Step 4: mysql_secure_installation..."
mysql -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';"
mysql_secure_installation <<EOF
n
y
N
y
y
EOF

# Step 5: Creating Zabbix DB
echo "Step 5: Creating Zabbix DB and MySQL user..."
mysql -uroot <<EOF
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'Password2025!';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
QUIT;
EOF

# Step 6: Schema importing
echo "Step 6: Importing schema DB, waiting in this step..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -pPassword2025! zabbix

# Step 7: Disabling log_bin_trust_function_creators
echo "Step 7: Disabling log_bin_trust_function_creators..."
mysql -uroot <<EOF
SET GLOBAL log_bin_trust_function_creators = 0;
QUIT;
EOF

# Step 8: Configuring Zabbix Server
echo "Step 8: Optimizing Zabbix server..."
sed -i 's/# DBPassword=/DBPassword=Password2025!/' /etc/zabbix/zabbix_server.conf
sed -i 's/# ValueCacheSize=8M/ValueCacheSize=64M/' /etc/zabbix/zabbix_server.conf

# Step 9: Optimizing MySQL
echo "Step 9: Optimizing MySQL..."
# Verify if the file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "the file $CONFIG_FILE doesn't exist"
    exit 1
fi

# Security Backup
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"

# Changing the values
sed -i -E 's|^#[[:space:]]*log_bin[[:space:]]*=.*$|log_bin = /var/log/mysql/mysql-bin.log|' "$CONFIG_FILE"
sed -i -E 's|^#[[:space:]]*binlog_expire_logs_seconds[[:space:]]*=.*$|binlog_expire_logs_seconds     = 432000|' "$CONFIG_FILE"


# Step 10: Enabling Zabbix
echo "Step 10: Enabling and running zabbix services..."
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

# Step 11: Configuring Firewall
echo "Step 11: Enabling firewall..."
sudo ufw allow 80/tcp
sudo ufw allow 10050/tcp
sudo ufw allow 10051/tcp
sudo ufw allow 3306/tcp

# Final message
echo "Installation complete reach your server on the browser: http://yourip/zabbix!"
