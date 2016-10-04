# This script shows how to the function dbaGetServiceAccount()
# to retrieve the accounts that run the specified services on
# either the local server or a remote server.

# The function is imported from the module SQLDBA::Security

use strict;
use SQLDBA::Security qw( dbaGetServiceAccount );  # import the function

# Specify the servers and their service names
# In this hash, LINCHI is the server name and its service names
# are listed in the array it references. To run this script on
# your machine, you need to modify the server names and service names.
my %services = ( LINCHI => ['MSSQLServer', 'MSSQL$APOLLO', 'SQLServerAgent'] );

# Loop through the servers in the hash
foreach my $server (keys %services) {
   # Loop through the service names in the array
   foreach my $service (@{$services{$server}}) {
       # Retrieve the service account
       my $acct = dbaGetServiceAccount($server, $service);
       print "Server: $server, Service: $service, Account: $acct\n";
   }
}