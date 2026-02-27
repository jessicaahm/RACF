# Usage: wsadmin -lang jython -f updatepassword.py <AliasName> <PasswordFile>
import sys

# Parameters
aliasName = sys.argv[0]
passwordFile = sys.argv[1]

# Read new password from file
f = open(passwordFile, 'r')
newPassword = f.read().strip()
f.close()

# Find the JAASAuthData object by alias attribute
allAuthData = AdminConfig.list('JAASAuthData').splitlines()
authData = None
for entry in allAuthData:
    entryAlias = AdminConfig.showAttribute(entry, 'alias')
    if entryAlias == aliasName or entryAlias.endswith('/' + aliasName):
        authData = entry
        break

if authData:
    fullAlias = AdminConfig.showAttribute(authData, 'alias')
    userId = AdminConfig.showAttribute(authData, 'userId')
    print "Updating password for alias: " + fullAlias

    # Use AdminTask for live runtime update (updates running server, no restart needed)
    # List format avoids special character parsing issues with passwords containing & * etc.
    AdminTask.modifyAuthDataEntry(['-alias', fullAlias, '-user', userId, '-password', newPassword])

    # Save to disk
    AdminConfig.save()
    print "Password updated and configuration saved."

    # Purge connection pool so new credentials take effect immediately
    dsQuery = AdminControl.queryNames('type=DataSource,*')
    for dsObj in dsQuery.splitlines():
        try:
            AdminControl.invoke(dsObj, 'purgePoolContents', '[0]', '[java.lang.Integer]')
            print "Connection pool purged: " + dsObj
        except:
            pass
else:
    print "Alias " + aliasName + " not found."
