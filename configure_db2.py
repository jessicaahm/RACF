# Create JDBC Provider using node scope
AdminTask.createJDBCProvider('[-scope Node=DefaultNode01,Server=server1 -databaseType DB2 -providerType "DB2 Using IBM JCC Driver" -implementationType "Connection pool data source" -name "DB2 JCC Provider" -classpath /opt/IBM/db2drivers/db2jcc4.jar]')
print "JDBC Provider created"

# Create J2C Auth Alias
AdminTask.createAuthDataEntry('[-alias DB2Auth -user db2inst1 -password db2pass123]')
print "Auth alias created"

# Create Data Source
provider = AdminConfig.getid('/JDBCProvider:DB2 JCC Provider/')
AdminTask.createDatasource(provider, '[-name MyDB2DS -jndiName jdbc/mydb2 -dataStoreHelperClassName com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper -componentManagedAuthenticationAlias DB2Auth -configureResourceProperties [[databaseName java.lang.String TESTDB] [serverName java.lang.String db2] [portNumber java.lang.Integer 50000] [driverType java.lang.Integer 4]]]')
print "Data source created"

# Set container-managed auth alias so testConnection uses DB2Auth by default
ds = AdminConfig.getid('/DataSource:MyDB2DS/')
AdminConfig.modify(ds, [['authDataAlias', 'DB2Auth']])
mapping = AdminConfig.showAttribute(ds, 'mapping')
if mapping:
    AdminConfig.modify(mapping, [['mappingConfigAlias', 'DefaultPrincipalMapping'], ['authDataAlias', 'DB2Auth']])
else:
    AdminConfig.create('MappingModule', ds, [['mappingConfigAlias', 'DefaultPrincipalMapping'], ['authDataAlias', 'DB2Auth']])
print "Container-managed auth alias set"

# Save
AdminConfig.save()
print "Configuration saved"
