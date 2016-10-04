use strict;
use Win32::Lanman;   # will use the NetShareEnum() function


# The servers whose shares will be enumerated are SQL1 and SQL2
# To test this script in your own environment, you need to change
# these names to the severs in your environment.

# You don't need any special rights on these servers as long as
# you can see them in your network neighborhood.

my @servers = ('W5114', 'ejecmapsql02');

# Loop through the servers and enumerate the shares on each server
foreach my $server (@servers) {
   my $shareRef = dbaGetShares($server);
   print "Server = $server\n";
   foreach my $share (@$shareRef) {
      print "\t$share\n";
   }
}

#####################
sub dbaGetShares {
   my ($server) = shift or 
        die "***Err: dbaGetShares() expects a server name.";

   my @shares;
   Win32::Lanman::NetShareEnum($server, \@shares) or
        do { print Win32::FormatMessage(Win32::Lanman::GetLastError());
               return;
         };
   my $shareRef;
   foreach my $share (@shares) {
      push @{$shareRef}, $share->{netname};
   }
   return $shareRef;
}  # dbaGetShares