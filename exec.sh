#!/bin/sh
LOG=/proc/1/fd/1

apk add --no-cache sshpass openssh-client >> $LOG 2>&1
echo "[exec.sh] Writing password to /tmp/VAULT" > $LOG
echo "$PASSWORD" > /tmp/VAULT

echo "[exec.sh] Copy wsadmin password update via SSH" > $LOG
sshpass -p 'password123' scp -o StrictHostKeyChecking=no /tmp/VAULT root@172.19.0.2:/tmp/VAULT

echo "[exec.sh] Running wsadmin password update via SSH" > $LOG
sshpass -p 'password123' ssh -o StrictHostKeyChecking=no root@172.19.0.2 \
    '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype SOAP -user wsadmin -password password123 -f /tmp/updatepassword.py DB2Auth /tmp/VAULT' >> $LOG 2>&1

echo "[exec.sh] restart WAS" > $LOG
sshpass -p 'password123' ssh -o StrictHostKeyChecking=no root@172.19.0.2 \
    '/opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -user wsadmin -password password123 && /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1' >> $LOG 2>&1
echo "[exec.sh] Done" > $LOG
tail -f /dev/null
 