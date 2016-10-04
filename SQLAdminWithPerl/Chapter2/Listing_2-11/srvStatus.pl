# This script illustrates how to use the module Win32::Service to
# retrieve the status of a service on the local or remote server.

use strict;
use Win32::Service qw( GetServices GetStatus );
use Data::Dumper;

# Get the server name from the command line
my $serverName = shift or die "***Err: $0 expects a server name.";
my ($key, %services, %status);

# Get all the configured services on the server
GetServices($serverName,\%services);
print '\\%services: ',Dumper(\%services);

# Loop through all the services
foreach $key (keys %services){
   if ($key =~ /^MSSQL/i) {     # interested in only MSSQL services
       # Retrieve the service status
       GetStatus($serverName, $services{$key}, \%status);
       print "$key: \\%status: ", Dumper(\%status);
   }
}
