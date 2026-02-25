export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

echo "1. Setup passphrase"
vault write /sys/policies/password/racf-passphrase \
  policy=@racf-policy-passphrase.hcl

# Read
vault read /sys/policies/password/racf-passphrase

# Enable LDAP Secret Engine - Passphrase
vault secrets enable -path racfpassphrase ldap

# Set up
vault write racfpassphrase/config @ldap-passphrase.json

echo "2. Create a static role"
vault write racfpassphrase/static-role/passphrase @ldap-role.json
vault read racfpassphrase/static-role/passphrase

# Rotate
vault write -f racfpassphrase/rotate-role/passphrase

# Read the creds
echo "3. Login"
export PASSWORD=$(vault read -field=password racfpassphrase/static-cred/passphrase)
LDAPTLS_REQCERT=never ldapsearch -H ldaps://9.85.77.229:636 -D "racfid=LDAPT01,profiletype=user,cn=ZOSEVD01" -w $PASSWORD -s base -b "racfid=LDAPT01,profiletype=user,cn=ZOSEVD01" "objectclass=*"
