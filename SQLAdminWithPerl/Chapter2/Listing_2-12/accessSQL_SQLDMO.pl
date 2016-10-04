# This script illustrates how to use the module Win32::OLE to invoke 
# SQLDMO via Automation. 

use strict;
use Win32::OLE;

# Get the SQL Server instance name from the command line
#    ServerName\InstanceName for a named instance
#    ServerName for the default instance
my $serverName = shift 
    or die "***Err: $0 expects a SQL instance name.";

# Request to create a SQLDMO.SQLServer2 object
my $server = Win32::OLE->new('SQLDMO.SQLServer2')
     or die "**Err: could not create SQLDMO object.";

# Set the COM object to use trusted SQL connection 
$server->{LoginSecure} = 1;

# Make a SQL connection. Note the login and password are
# not even present.
$server->Connect($serverName);
! Win32::OLE->LastError()
    or die "***Err: could not connect to $serverName.";

print $server->INSTANCEname, "\n";
print $server->StartupAccount, "\n";
print $server->{ServiceName}, "\n";
print $server->{VersionString}, "\n";
print $server->Databases()->{Count};

# Close the connection
$server->Disconnect;
