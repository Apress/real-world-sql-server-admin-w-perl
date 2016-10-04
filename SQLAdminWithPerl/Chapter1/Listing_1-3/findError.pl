# Listing 1-3

use strict;

Main: {
   my $log = shift or die "***Err: $0 expects a file name.\n";
   open(LOG, "$log") or die "***Err: couldn't open $log.\n";
   while (<LOG>) {
      findPattern($_); 
   }
   close(LOG);
} # Main

###################
sub findPattern {
    my $line = shift or die "***Err: function findPattern() expects a string.\n";
    if ($line =~ /Error:\s+\d+,     # error number
                  \s+               # space
                  Severity:\s+(\d+) # severity level
                 /ix) {
            print $line if $1 >= 17;
    }
} # findPattern
