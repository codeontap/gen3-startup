#!/bin/bash
# EFS_FILE_SYSTEM_ID - Environment Variable - The ID of the EFS File System
# EFS_MOUNT_PATH - Environment Variable - The Path on the EFS File System
# EFS_OS_MOUNT_PATH - Environment Variable - Location on the OS where the share should mount
# EFS_CREATE_MOUNT - Environment Variable - Create the mount on the EFS Share
# EFS_IAM_ENABLED - Environment Variable - To use IAM or not
# EFS_ACCESS_POINT_ID - Environment Variable - Use an EFS Access point for the mount location
# Assumes amazon-efs-utils has been installed already

EFS_IAM_ENABLED="${EFS_IAM_ENABLED:-false}"
EFS_CREATE_MOUNT="${EFS_CREATE_MOUNT:-true}"

# Mount EFS to a temp directory and create the EFS path if it doesn't exist
# Thie ensures the permanent mount works as expected
if [[ "${EFS_CREATE_MOUNT}" == "true" ]]; then
    temp_dir="$(mktemp -d -t efs.XXXXXXXX)"
    mount -t efs "${EFS_FILE_SYSTEM_ID}:/" ${temp_dir} || exit $?
    if [[ ! -d "${temp_dir}/${EFS_MOUNT_PATH}" ]]; then
        mkdir -p "${temp_dir}/${EFS_MOUNT_PATH}"

        # Allow Full Access to volume (Allows for unkown container access )
        chmod -R ugo+rwx "${temp_dir}/${EFS_MOUNT_PATH}"
    fi
    umount ${temp_dir}
fi

# Build mount options
EFS_OPTIONS=( "_netdev" "tls" )
if [[ "${EFS_IAM_ENABLED}" == "true" ]]; then
    EFS_OPTIONS+=('iam')
fi

if [[ -n "${EFS_ACCESS_POINT_ID}" ]]; then
    EFS_OPTIONS+=("accesspoint=${EFS_ACCESS_POINT_ID}")
fi

EFS_OPTIONS="$(IFS=,; echo "${EFS_OPTIONS[*]}")"

# Create and Mount volume
mkdir -p ${EFS_OS_MOUNT_PATH}
mount -t efs -o "${EFS_OPTIONS}" "${EFS_FILE_SYSTEM_ID}:${EFS_MOUNT_PATH}" "${EFS_OS_MOUNT_PATH}" || exit $?

# Add to permanent mount in case of reboots
echo -e "${EFS_FILE_SYSTEM_ID}:${EFS_MOUNT_PATH} ${EFS_OS_MOUNT_PATH} efs ${EFS_OPTIONS} 0 0" >> /etc/fstab
