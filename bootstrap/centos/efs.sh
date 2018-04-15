#!/bin/bash
# Assumes EFS_FILE_SYSTEM_ID - Environment Variable - The ID of the EFS File System 
# Assumes EFS_MOUNT_PATH - Environment Variable - The Path on the EFS File System
# Assumes EFS_OS_MOUNT_PATH - Environment Variable - Location on the OS where the share should mount 
# Assumes nfs-utils has been installed already 

# Find AZ
EC2_AVAIL_ZONE="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
EC2_REGION=$(/etc/codeontap/facts.sh | grep cot:accountRegion= | cut -d '=' -f 2)

EFS_PATH="${EC2_AVAIL_ZONE}.${EFS_FILE_SYSTEM_ID}.efs.${EC2_REGION}.amazonaws.com"

# Create and Mount volume
mkdir -p ${EFS_OS_MOUNT_PATH}
echo -e "${EFS_PATH}:${EFS_MOUNT_PATH} ${EFS_OS_MOUNT_PATH} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
mount -a

# Allow Full Access to volume (Allows for unkown container access )
#TODO(roleyfoley): Look at System Manager as potential fix for this
chmod -R ugo+rwx ${EFS_OS_MOUNT_PATH}