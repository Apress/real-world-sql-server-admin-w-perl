use strict;

# Use the Time::Local module to convert the date/time elements\
# into the Epoch seconds

use Time::Local;

# Get the date/time string from the command line
my $timestr = shift or die "$0 expects a date time string.";

# validate the input string    
if ($timestr =~ /(\d\d\d\d)(\/|-)(\d\d)(\/|-)(\d\d)   # date portion
                 (\s+(\d\d):(\d\d):(\d\d))?           # time portion
                /x) {     
    print "Epoch seconds = ", 
          timelocal($9, $8, $7, $5, $3 - 1, $1 - 1900);
}
else {
    print "$timestr is not in the YYYY/MM/DD hh:mm:ss format.\n";

}