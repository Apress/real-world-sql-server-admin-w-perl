# Listing 1-2

use strict;

my $log = shift 
    or die "***Err: a file is expected on the command line.";
open(LOG, "$log") 
    or die "***Err: couldn't open $log.";

while(<LOG>) {
   dummy($_);
}
close(LOG);

#############
sub dummy {
    my $line = shift or die "***Err: function dummy() expects a string.";
    print $line;
} # dummy
