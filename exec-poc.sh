#!/bin/sh
LOG=/tmp/vault.log
#LOCAL ENVIRONMENT
DIRECTORY="/opt/IBM/WebSphere/AppServer/bin"
VAULT_HOME="/tmp"
ALIAS="vrldwas01aManager01/vd01was1"
WAS_IP_ADDRESS="172.20.1.10"

# POC ENVIRONMENT --> PLEASE CHANGE TO THIS
# DIRECTORY="/vrl/appl/WebSphere90/AppServer/profiles/Dmgr01/bin"
# VAULT_HOME="/home/vault"
# ALIAS="DefaultNode01/DB2Auth"
# WAS_IP_ADDRESS=""

echo "[exec.sh] Running wsadmin password update via SSH" > $LOG
ssh -o StrictHostKeyChecking=no root@$WAS_IP_ADDRESS \
    "export PASSWORD='$PASSWORD'; $DIRECTORY/wsadmin.sh -lang jython -conntype SOAP -user wsadmin -f $VAULT_HOME/update_j2c_password.py $ALIAS" >> $LOG 2>&1

 