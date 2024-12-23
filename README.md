# zabbix_datacenter_monitoring
Bash script for deploying Zabbix 6.4 on Ubuntu 22.04 with optimized settings for datacenter environments.

# Zabbix 6.4 Installation and Configuration on Ubuntu 22.04

This repository contains a Bash script for automating the installation and configuration of Zabbix 6.4 on an Ubuntu 22.04 server using the LAMP stack.

---

## **Introduction**

Zabbix is a powerful monitoring platform for IT infrastructures.  
This script was tested in a real-world datacenter scenario that provided hosting and management services for virtual machines running specific applications.  

### **Test Environment**
- **80 VMs** (Linux and Windows).
- **4 hyper-converged cluster virtualizers**.
- **2 layer switches**.
- **2 firewalls in HA**.
- **1 enterprise NAS** for secure VM backups.

### **Recommended Hardware Requirements for Virtual machine**
- **130GB SSD** (SSD virtual hard disk).
- **8GB RAM**.
- **4 vCPUs**.

---

## **Optimizations Applied**

### **1. Zabbix Server Optimization**
In the configuration file `/etc/zabbix/zabbix_server.conf`, the `ValueCacheSize` value was adjusted to **64MB**.  

**Benefits**:
- Provides better stability for environments with a high number of monitored metrics (80+ VMs).
- Enhances performance for caching metrics.

---

### **2. MySQL Optimization**
In the configuration file `/etc/mysql/mysql.conf.d/mysqld.cnf`, the following changes were made:  
1. **Uncommented and configured**:  
   ```ini
   log_bin = /var/log/mysql/mysql-bin.log
   binlog_expire_logs_seconds = 432000
   max_binlog_size   = 100M
   
**Benefits**:
- Reduces disk space used by binary logs while maintaining an adequate recovery window
- Efficient File Management: Smaller, more manageable log files improve read/write speed and simplify replication.
- binlog_expire_logs_seconds = 432000 (from 2592000, equivalent to 30 days, to 432000, equivalent to 5 days).


## How to Run the Script

1. **Update the system
   ```bash
   sudo su
   apt update && apgrade -y

2. **Clone the repository
   ```bash
   git clone https://github.com/eugeniogiusti/zabbix_datacenter_monitoring.git
   cd zabbix_datacenter_monitoring


3. **Make the script executable:
   ```bash
   chmod +x install_zabbix.sh


4. **Run the script as root:
   ```bash
   sudo ./install_zabbix.sh


5. **Access the Zabbix Frontend / Find the server’s IP address:
   ```bash
   http://yourlocalip/zabbix


6. **Complete the initial configuration wizard:
Enter the database details configured by the script:

Database Name: zabbix
User: zabbix
Password: Password2025!

Follow the steps to finish the setup.
Log in to the Zabbix dashboard with the default credentials:

   ```bash
   Username: Admin
   Password: zabbix
