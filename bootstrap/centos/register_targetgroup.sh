#!/bin/bash -ex
# Assumes target group is passed as an environment variable
exec > >(tee /var/log/codeontap/register.log|logger -t codeontap-register -s 2>/dev/console) 2>&1
INSTANCE="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
AVAILABILITY_ZONE="$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION=${AVAILABILITY_ZONE::-1}
aws --region "${REGION}" elbv2 register-targets --target-group-arn "${TARGET_GROUP_ARN}" --targets "Id=${INSTANCE}"