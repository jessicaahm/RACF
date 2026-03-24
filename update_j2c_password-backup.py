# ========================================================================
# Script Name  : update_j2c_password.py
# Purpose      : Update J2C Authentication Alias Password
# Usage        : wsadmin.sh -lang jython -f update_j2c_password.py DB2Auth newPassword
# ========================================================================

import sys

if len(sys.argv) != 2:
    print "Usage: wsadmin.sh -lang jython -f update_j2c_password.py <AliasName> <NewPassword>"
    sys.exit(1)

aliasName = sys.argv[0]
newPassword = open(sys.argv[1]).read().strip()

print "Updating J2C Alias: " + aliasName

# ------------------------------------------------------------------------
# Find J2C alias
# ------------------------------------------------------------------------

j2cList = AdminConfig.list("JAASAuthData").splitlines()

aliasId = None

for j2c in j2cList:
    alias = AdminConfig.showAttribute(j2c, "alias")
    print "DEBUG found alias: [" + alias + "]"
    shortName = aliasName.split('/')[-1]
    if alias == aliasName or alias == shortName or alias.endswith('/' + shortName) or alias.endswith(':' + shortName):
        aliasId = j2c
        break

if aliasId is None:
    print "ERROR: Alias not found!"
    sys.exit(1)

# ------------------------------------------------------------------------
# Update Password
# ------------------------------------------------------------------------

AdminConfig.modify(aliasId, [["password", newPassword]])

print "Password updated for alias: " + aliasName

# ------------------------------------------------------------------------
# Save Configuration
# ------------------------------------------------------------------------

AdminConfig.save()
print "Configuration saved."

# ------------------------------------------------------------------------
# Optional: Sync Nodes (ND Only)
# ------------------------------------------------------------------------

try:
    nodes = AdminControl.queryNames("type=NodeSync,*").splitlines()
    for node in nodes:
        print "Syncing node: " + node
        AdminControl.invoke(node, "sync")
except:
    print "Node sync skipped (likely Base profile)."

# TEST APP
# AdminControl.invoke(appManager, 'stopApplication', 'AppName')
# AdminControl.invoke(appManager, 'startApplication', 'AppName')

print "J2C password update completed successfully."