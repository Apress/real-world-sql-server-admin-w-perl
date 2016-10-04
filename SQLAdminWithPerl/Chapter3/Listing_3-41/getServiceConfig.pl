# This script shows how to use the module Win32::Lanman
# to query the configurations of a service.

use Win32::Lanman;
use Data::Dumper;

# Specify the test server name and service name
my ($server, $service) = ('LINCHI', 'MSSQL$APOLLO');

# The service config info is to be returned in this hash   
my %srvConfig;  

# Retrieve the service configurations
if(Win32::Lanman::QueryServiceConfig("\\\\$server", '', 
                                      $service,\%srvConfig)) {
    print Dumper(\%srvConfig);
}
else {
    die "***Err: Lanman::QueryServiceConfig encountered an error for " .
                  "$server and $service. " . Win32::Lanman::GetLastError();
}
