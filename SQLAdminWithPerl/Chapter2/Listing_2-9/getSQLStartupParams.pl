# This script shows how to use the Win32::TieRegistry module to
# retrieve the startup parameters of a SQL Server named 
# instance. For illustration purposes, it doesn't work with
# the default instance. It's very easy to modify the script to
# work with the default instance.

use strict;
use Win32::TieRegistry (Delimiter => '/');

# Get the two expected command line parameters
my $server = shift 
    or die "***Err: $0 expects the 1st parameter to be a server name";
my $instance = shift 
    or die "***Err: $0 expects the 2nd parameter to be a named instance";

# Specify the registry path for the startup parameters
my $sqlKey = $Registry->{"//$server/LMachine/Software/Microsoft/Microsoft SQL Server/"};
my $pkey = $sqlKey->{$instance . '/MSSQLServer/Parameters/'};

# Enumerate the registry values under the key
foreach my $value (keys %{$pkey}) {
   $value =~ s/^\///;
   print "$value = $pkey->{'/' . $value}\n";
}


