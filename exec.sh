#!/bin/sh
LOG=/proc/1/fd/1
#LOCAL ENVIRONMENT
DIRECTORY="/opt/IBM/WebSphere/AppServer/bin"
VAULT_HOME="/tmp"
ALIAS="DefaultNode01/DB2Auth"

# POC ENVIRONMENT --> PLEASE CHANGE TO THIS
# DIRECTORY="/vrl/appl/WebSphere90/AppServer/profiles/Dmgr01/bin"
# VAULT_HOME="/home/vault"

echo "[exec.sh] Copy updatepassword.py via SSH" > $LOG
sshpass -p 'password123' scp -o StrictHostKeyChecking=no $VAULT_HOME/update_j2c_password.py root@172.19.0.2:/tmp/update_j2c_password.py

apk add --no-cache sshpass openssh-client >> $LOG 2>&1
echo "[exec.sh] Writing password to /tmp/VAULT" > $LOG
echo "$PASSWORD" > /tmp/VAULT
#echo "$PASSWORD updated"

echo "[exec.sh] Copy wsadmin password update via SSH" > $LOG
sshpass -p 'password123' scp -o StrictHostKeyChecking=no /tmp/VAULT root@172.19.0.2:/tmp/VAULT

echo "[exec.sh] Running wsadmin password update via SSH" > $LOG
sshpass -p 'password123' ssh -o StrictHostKeyChecking=no root@172.19.0.2 \
    "$DIRECTORY/wsadmin.sh -lang jython -conntype SOAP -user wsadmin -password password123 -f /tmp/update_j2c_password.py $ALIAS /tmp/VAULT" >> $LOG 2>&1

# Please make changes to the app name to do testing
echo "[exec.sh] Restarting db2test to clear stale connection pool" > $LOG
sshpass -p 'password123' ssh -o StrictHostKeyChecking=no root@172.19.0.2 \
    "$DIRECTORY/wsadmin.sh -lang jython -conntype SOAP -user wsadmin -password password123 \
     -c \"mgr=AdminControl.queryNames('type=ApplicationManager,process=server1,*'); AdminControl.invoke(mgr,'stopApplication','db2test'); AdminControl.invoke(mgr,'startApplication','db2test')\"" >> $LOG 2>&1

tail -f /dev/null
 