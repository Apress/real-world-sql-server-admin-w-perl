# Listing 1-4

use strict;

my $log = shift 
    or die "***Err: $0 expects a file name on the command line.\n";
open(LOG, "> $log") 
    or die "***Err: could not open $log for write.\n";
print LOG ("Logging starts at ", scalar localtime(), "\n");

# do other things

close(LOG);
