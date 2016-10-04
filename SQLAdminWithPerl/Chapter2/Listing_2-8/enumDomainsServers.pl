# This script enumerates all the domains accessible from the 
# machine where you run this script.
# For each domain, it enumerates all the NT servers in the domain.

use strict;
use Win32::NetAdmin;

# Set the flag to force flushing the output buffer after each write

$| = 1; 

my @domains;
my @servers;

# Now enumerate domains. This populates the array @domains
# Note the use of the constant SV_TYPE_DOMAIN_ENUM which is
# imported by default from the module Win32::NetAdmin

Win32::NetAdmin::GetServers( '', '', SV_TYPE_DOMAIN_ENUM, \@domains);

# For each domain, enumerate the NT machines. The constant SV_TYPE_NT
# is again imported from the module Win32::NetAdmin by default.

foreach my $domain (sort @domains) {
   print "   *** Domain: $domain";

   # now enumerate machines in the domain
   Win32::NetAdmin::GetServers( '', $domain, SV_TYPE_NT, \@servers);
   print "\t\t Found ", scalar @servers, " NT machines in this domain\n";

   foreach my $server (sort @servers) {
         print "\t\t $server\n";
   }
}
