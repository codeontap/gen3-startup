#!/bin/bash -ex

# -- Configure Time 
exec > >(tee /var/log/codeontap/time.log|logger -t codeontap-time -s 2>/dev/console) 2>&1

# Package Cleanup 
yum erase ntp*
yum install chrony

# Set chrony to the AWS Time Sync Service
echo "" >> /etc/chrony.conf 
echo "server 169.254.169.123 prefer iburst" >> /etc/chrony.conf 

/sbin/service chronyd start
/sbin/chkconfig chronyd on

# set timezone if we have received it
if [[ -n "${TIMEZONE}" ]]; then 
    /usr/bin/sed -i -e "s/ZONE=UTC/ZONE=${TIMEZONE}/g" /etc/sysconfig/clock
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
fi 

