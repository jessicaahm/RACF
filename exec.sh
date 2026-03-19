#!/bin/sh
LOG=/tmp/vault.log
#LOCAL ENVIRONMENT
DIRECTORY="/opt/IBM/WebSphere/AppServer/bin"
VAULT_HOME="/tmp"
ALIAS="DefaultNode01/DB2zOSAuth"
WAS_IP_ADDRESS="172.19.0.2"

# POC ENVIRONMENT --> PLEASE CHANGE TO THIS
# DIRECTORY="/vrl/appl/WebSphere90/AppServer/profiles/Dmgr01/bin"
# VAULT_HOME="/home/vault"
# ALIAS="vrldwas01aManager01/vd01was1"
# WAS_IP_ADDRESS="172.20.1.10"

#apk add --no-cache openssh-client >> $LOG 2>&1
echo "[exec.sh] Running wsadmin password update via SSH" >> $LOG
ssh -o StrictHostKeyChecking=no root@$WAS_IP_ADDRESS \
    "cd /tmp && export PASSWORD='$PASSWORD'; $DIRECTORY/wsadmin.sh -lang jython -conntype SOAP -f $VAULT_HOME/update_j2c_password.py $ALIAS" >> $LOG 2>&1

tail -f /dev/null