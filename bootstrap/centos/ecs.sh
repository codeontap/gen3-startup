#!/bin/bash -x
# Assumes ECS cluster is passed as an environment variable
exec > >(tee /var/log/codeontap/ecs.log|logger -t codeontap-ecs -s 2>/dev/console) 2>&1
REGION=$(/etc/codeontap/facts.sh | grep cot:accountRegion= | cut -d '=' -f 2)
CREDENTIALS=$(/etc/codeontap/facts.sh | grep cot:credentials= | cut -d '=' -f 2)
ACCOUNT=$(/etc/codeontap/facts.sh | grep cot:account= | cut -d '=' -f 2)

# Check if a template for the ECS config has been provided
aws --region ${REGION} s3 cp s3://${CREDENTIALS}/${ACCOUNT}/alm/docker/ecs.config /etc/ecs/ecs.config

# Capture the current configuration
if [[ -f /etc/ecs/ecs.config ]]; then
    . /etc/ecs/ecs.config
else
    touch /etc/ecs/ecs.config
    # Defaults
    [[ -z "${ECS_AVAILABLE_LOGGING_DRIVERS}" ]] && ECS_AVAILABLE_LOGGING_DRIVERS="[\"json-file\",\"syslog\",\"journald\",\"gelf\",\"fluentd\",\"awslogs\"]"
    [[ -z "${ECS_LOGLEVEL}" ]] && ECS_LOGLEVEL=warn
    [[ -z "${ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION}" ]] && ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m
fi

# Update the ECS agent configuration
SETTINGS=("ECS_CLUSTER" "ECS_LOGLEVEL" "ECS_AVAILABLE_LOGGING_DRIVERS" "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION" )
for SETTING in "${SETTINGS[@]}" ; do
    if [[ -n "${!SETTING}" ]]; then
        if grep "${SETTING}" /etc/ecs/ecs.config  ; then
            sed -i "s,^\(${SETTING}=\).*,\1${!SETTING},g" /etc/ecs/ecs.config
        else
            echo "${SETTING}=${!SETTING}" >> /etc/ecs/ecs.config
        fi
    fi
done

# Add default log driver to docker startup options if provided
# If its cloud watch logging, ignore
if [[ (-n "${ECS_LOG_DRIVER}") && ("${ECS_LOG_DRIVER}" != "awslogs") ]]; then
	. /etc/sysconfig/docker
	if [[ -n "${OPTIONS}" ]]; then
            sed -i "s,^\(OPTIONS=\).*,\1\"${OPTIONS} --log-driver=${ECS_LOG_DRIVER}\",g" /etc/ecs/ecs.config
	else
		echo "OPTIONS=\"--log-driver=${ECS_LOG_DRIVER}\"" >> /etc/sysconfig/docker
	fi
fi

# Restart docker to ensure it picks up any EBS volume mounts and updated configuration settings
# - see https://github.com/aws/amazon-ecs-agent/issues/62
/sbin/service docker restart 
/sbin/start ecs
