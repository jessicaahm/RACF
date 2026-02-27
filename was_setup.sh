# Setup WAS [Only for Lab environment]

docker pull --platform linux/amd64 icr.io/appcafe/websphere-traditional:latest

docker network create was-db2-net

docker run --platform linux/amd64 --name db2 --network was-db2-net \
  -e DB2INST1_PASSWORD=db2pass123 -e DBNAME=TESTDB -e LICENSE=accept \
  -p 50000:50000 --privileged -d icr.io/db2_community/db2

# docker run --platform linux/amd64 --name test --network was-db2-net \
#   -h test -v $(pwd)/PASSWORD/PASSWORD:/tmp/PASSWORD \
#   -p 9043:9043 -p 9443:9443 -d icr.io/appcafe/websphere-traditional

docker run --platform linux/amd64 --name test --network was-db2-net \
  -h test -v $(pwd)/PASSWORD/PASSWORD:/tmp/PASSWORD \
  -p 9043:9043 -p 9443:9443 -p 2222:22 \
  -d icr.io/appcafe/websphere-traditional \
  /bin/bash -c "/opt/IBM/WebSphere/AppServer/bin/startServer.sh server1; tail -f /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1/SystemOut.log"

# Change password
docker exec -it test wsadmin.sh -lang jython -conntype NONE \
  -c "AdminTask.changeFileRegistryAccountPassword('[-userId wsadmin -password password123]')" \
  -c "AdminConfig.save()"


# docker run --platform linux/amd64 --name test --network was-db2-net \
#   -h test -v $(pwd)/PASSWORD/PASSWORD:/tmp/PASSWORD \
#   -p 9043:9043 -p 9443:9443 -p 2222:22 \
#   -d icr.io/appcafe/websphere-traditional

# copy files
docker cp db2:/opt/ibm/db2/V12.1/java/db2jcc4.jar ./db2jcc4.jar && \
docker exec -it test mkdir -p /opt/IBM/db2drivers && \
docker cp db2jcc4.jar test:/opt/IBM/db2drivers/db2jcc4.jar

# restart
# docker exec -it test /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -user wsadmin -password password123 
# docker exec -it test /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1
# wait for server to be ready
docker exec -it test bash -c 'until [ -f /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1/server1.pid ]; do echo "Waiting for server1..."; sleep 10; done'

# configure db2
docker cp configure_db2.py test:/tmp/configure_db2.py
docker exec -it test wsadmin.sh -lang jython -conntype NONE -f /tmp/configure_db2.py

# Manually check password / update password
# Security > Global Security
# Under Authentication, expand Java Authentication and Authorization Service
# Click J2C authentication data
# Click New
# Alias: DB2Auth
# User ID: db2inst1
# Password: db2pass123
# Click Apply then Save

# Manually test connection
# Go to Resources > JDBC > Data Sources
# Select the checkbox next to MyDB2DS
# Click Test connection
# You should see: "Test connection for data source MyDB2DS was successful"

# ADMU0116I: Tool information is being logged in file
#            /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1/serverStatus.log
# ADMU0128I: Starting tool with the AppSrv01 profile
# ADMU0500I: Retrieving server status for server1
# Realm/Cell Name: <default>
# Username: wsadmin
# Password: 
#  ADMU0508I: The Application Server "server1" is STARTED

# Check WAS Version
docker exec -it test /opt/IBM/WebSphere/AppServer/bin/versionInfo.sh

# Acccess WAS - Check security.xml
docker exec -it test grep -i "serverPassword\|bindPassword\|password" /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/config/cells/DefaultCell01/security.xml

docker exec -it test wsadmin.sh -lang jython -conntype NONE

docker exec -it test wsadmin.sh -lang jython -conntype NONE -c \
  "AdminTask.changeFileRegistryAccountPassword('[-userId wsadmin -password newpassword]')" -c "AdminConfig.save()"


# Access console at: https://localhost:9043/ibm/console
# REFERENCE: https://www.ibm.com/docs/en/was/8.5.5?topic=tool-updating-default-key-store-passwords-using-scripting


# Start DB2
docker exec -it db2 su - db2inst1 -c "db2start"
# Check DB2 Status
docker exec -it db2 su - db2inst1 -c "db2gcf -s"

# Test DB2 connection
docker exec -it db2 su - db2inst1 -c "db2 connect to TESTDB user db2inst1 using db2pass123"

# jessica@Jessicas-MacBook-Pro RACF % docker exec -it db2 su - db2inst1 -c "db2 connect to TESTDB user db2inst1 using db2pass123"


#    Database Connection Information

#  Database server        = DB2/LINUXX8664 12.1.3.0
#  SQL authorization ID   = DB2INST1
#  Local database alias   = TESTDB


# Change DB2 password (read from VAULT file)
NEW_DB2_PASS=$(cat ./PASSWORD/VAULT)

docker exec -it -e "NEW_PASS=${NEW_DB2_PASS}" db2 bash -c 'su - db2inst1 -c "db2stop force" && echo "db2inst1:${NEW_PASS}" | chpasswd && su - db2inst1 -c "db2start"'
docker exec db2 su - db2inst1 -c "db2 connect to TESTDB user db2inst1 using '${NEW_DB2_PASS}'"

docker exec -it test wsadmin.sh -lang jython -user wsadmin -password password123 \
  -c "ds = AdminConfig.getid('/DataSource:MyDB2DS/')" \
  -c "print AdminControl.testConnection(ds)"

# WASX7209I: Connected to process "server1" on node DefaultNode01 using SOAP connector;  The type of process is: UnManagedProcess
# WASX7015E: Exception running command: "AdminControl.testConnection(ds)"; exception information:
# com.ibm.websphere.management.exception.AdminException
# javax.management.MBeanException
# java.sql.SQLNonTransientException: java.sql.SQLNonTransientException: [jcc][t4][10205][11234][4.36.6] Null userid is not supported. ERRORCODE=-4461, SQLSTATE=42815 DSRA0010E: SQL State = 42815, Error Code = -4,461

# Test script
docker cp updatepassword.py test:/tmp/updatepassword.py
docker cp ./PASSWORD/VAULT test:/tmp/VAULT
docker exec -it test wsadmin.sh -lang jython -conntype NONE -f /tmp/updatepassword.py DB2Auth /tmp/VAULT
docker exec -it test cat /tmp/VAULT

# jessica@Jessicas-MacBook-Pro RACF % docker exec -it test wsadmin.sh -lang jython -conntype NONE -f /tmp/updatepassword.py DB2Auth /tmp/VAULT

# WASX7357I: By request, this scripting client is not connected to any server process. Certain configuration and application operations will be available in local mode.
# WASX7303I: The following options are passed to the scripting environment and are available as arguments that are stored in the argv variable: "[DB2Auth, /tmp/VAULT]"
# Updating password for alias: DB2Auth
# Password updated and configuration saved.

# Install SSH Server to simulate file transfer (RHEL)
docker exec -u root -it test bash -c "
  yum install -y openssh-server &&
  mkdir -p /run/sshd &&
  ssh-keygen -A &&
  echo 'root:password123' | chpasswd &&
  sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
  sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config &&
  /usr/sbin/sshd -D &
"

# Check SSHD installed
docker exec -it test bash -c "which sshd"

# Add sshd to WAS startup script so it auto-starts
docker exec -u root test bash -c "
  echo '/usr/sbin/sshd' >> /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/bin/startServer.sh
"
docker exec -it test bash -c "pgrep sshd && echo 'sshd running'"

# start 
docker exec -u root test /usr/sbin/sshd


# sshd to IBM WAS
ssh root@localhost -p 2222

# test copying file
docker exec -it test cat /tmp/VAULT

docker exec -it agent sh -c "
  apk add --no-cache openssh-client sshpass &&
  sshpass -p 'password123' scp -o StrictHostKeyChecking=no /tmp/VAULT root@172.19.0.2:/tmp/VAULT &&
  sshpass -p 'password123' ssh -o StrictHostKeyChecking=no root@172.19.0.2 \
    '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype SOAP -user wsadmin -password password123 -f /tmp/updatepassword.py DB2Auth /tmp/VAULT'
"

# copy file to agent
docker cp exec.sh agent8400:/tmp/exec.sh

# check file
docker exec -it test bash -c "cat /tmp/VAULT"