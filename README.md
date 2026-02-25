# RACF - Password

> Note: RACF passphrase has to be more than 14 charters can be up to 100 characters.

```sh
# Attribute required by LDAPU001 and LDAPT001

#ssh
ssh LDAPU001@9.85.77.229

tsocmd "LU LDAPU001"
tsocmd "LU LDAPT01"
tsocmd "ALU LDAPT01 PASSWORD(ABCD1234) NOEXPIRED"

LU LDAPU001
# IKJ56644I NO VALID TSO USERID, DEFAULT USER ATTRIBUTES USED
# USER=LDAPU001  NAME=LDAP USER ID 001      OWNER=TSO2      CREATED=26.040  
#  DEFAULT-GROUP=GLD      PASSDATE=26.050 PASS-INTERVAL=254 PHRASEDATE=N/A    
#  ATTRIBUTES=SPECIAL  

 LU LDAPT01
# IKJ56644I NO VALID TSO USERID, DEFAULT USER ATTRIBUTES USED
# USER=LDAPT01  NAME=LDAP TEST ID 001      OWNER=TSO2      CREATED=26.043  
#  DEFAULT-GROUP=GLD      PASSDATE=26.055 PASS-INTERVAL=254 PHRASEDATE=N/A    
#  ATTRIBUTES=NONE  

# LDAP Modify
ldapmodify -h 9.85.77.229 -p 389 -D "racfid=LDAPU001,profiletype=user,cn=RACF" -w abcd1234 <<EOF
dn: racfid=LDAPT01,profiletype=user,cn=RACF
changetype: modify
replace: racfPassword
racfPassword: new2day
EOF

#Login with newpassword
ldapsearch -h 9.85.77.229 -p 389 -D "racfid=LDAPU001,profiletype=user,cn=RACF" -w abcd1234

```

# RACF - SSL / RACF
```sh
export LDAPTLS_CACERT=/Users/jessica/Library/CloudStorage/OneDrive-IBM/GitHub/demo/RACF/cert/Z32ACACert.pem
# Check Port
nc -zv 9.85.77.229 636

# Modify LDAP
ldapmodify -H ldaps://9.85.77.229:636 -D "racfid=LDAPU001,profiletype=user,cn=ZOSEVD01" -w abcd1234 <<EOF
dn: racfid=LDAPT01,profiletype=user,cn=ZOSEVD01
changetype: modify
replace: racfPassPhrase
racfPassPhrase: H8zW2kL9mP5rT3xV4qB6
-
replace: racfAttributes
racfAttributes: noexpired
EOF

# LDAP Search
ldapsearch -h ldaps://9.85.77.229 -p 636 -D "racfid=LDAPU001,profiletype=user,cn=ZOSEVD01" -w M3vQ9rL1xK7nB4tW6zG2 -s base -b "racfid=LDAPT01,profiletype=user,cn=ZOSEVD01" "objectclass=*"

# LDAP Search - without SSL
LDAPTLS_REQCERT=never ldapsearch -H ldaps://9.85.77.229:636 -D "racfid=LDAPU001,profiletype=user,cn=ZOSEVD01" -w M3vQ9rL1xK7nB4tW6zG2 -s base -b "racfid=LDAPT01,profiletype=user,cn=ZOSEVD01" "objectclass=*"
```
