# This script uses the module Win32::TieRegistry to retrieve
# information from the registry. For demonstration purposes,
# This script retrieves the CPU speed, the number of CPUs,
# and the CPU vendor ID recorded in the registry.


use strict;
use Win32::TieRegistry( Delimiter=>"/" );

# Get the server name from the command line
my $server = shift or 
   die "***Err: $0 expects a server name.";
my ($reg, $key, $speed, $numProc, $vendorID);

# Specify the registry keys for the CPU info
my %reg_keys = ( 
           cpu     => "//$server/HKEY_LOCAL_MACHINE/HARDWARE/DESCRIPTION/" .
                       "System/CentralProcessor/0/",
           numProc => "//$server/LMachine/SYSTEM/CurrentControlSet/" .
                       "Control/Session Manager/Environment/"
      );

# Get the CPU speed
$reg = $reg_keys{cpu};
$key = $Registry->{$reg} or die "***Err: Can't open key $reg on $server.";
$speed = $key->{'/~MHZ'} or die "***Err: Can't read ${reg}~MHZ on $server.";
$speed = int (((int(hex ($speed) /5) + 1) * 5));

# Get the number of CPUs
$reg = $reg_keys{numProc};
$key = $Registry->{$reg} or die "***Err: Can't open key $reg on $server.";
$numProc = $key->{'/NUMBER_OF_PROCESSORS'} or
   die "***Err: Can't read ${reg}NUMBER_OF_PROCESSORS on $server.";

# Get the CPU vendor ID  
$reg = $reg_keys{cpu};
$key = $Registry->{$reg} or die "***Err: Can't open key $reg of $server.";
$vendorID = $key->{'/VendorIdentifier'} or
   die "***Err: Can't read ${reg}VendorIdentifier on $server.";

# Output the results
print " Speed:      $speed\n";
print " Processors: $numProc\n";
print " VendorID:   $vendorID\n";

