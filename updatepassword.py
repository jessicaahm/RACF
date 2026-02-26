# Usage: wsadmin -lang jython -f updatepassword.py <AliasName> <PasswordFile>
import sys

# Parameters
aliasName = sys.argv[0]
passwordFile = sys.argv[1]

# Read new password from file
f = open(passwordFile, 'r')
newPassword = f.read().strip()
f.close()

# Find the JAASAuthData object
authData = AdminConfig.getid('/Node:*/JAASAuthData:' + aliasName + '/')

if authData:
    print "Updating password for alias: " + aliasName
    # Modify the password property
    AdminConfig.modify(authData, [['password', newPassword]])
    
    # Save the changes
    AdminConfig.save()
    print "Password updated and configuration saved."
else:
    print "Alias " + aliasName + " not found."
