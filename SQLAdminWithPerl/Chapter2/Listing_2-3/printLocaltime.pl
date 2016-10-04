# Printing the current time as YYYY/MM/DD hh:mm:ss

use strict;

# The localtime(0) returns the current date/time 
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(0);

# Print the date/time
# Note that $year is the number of years since 1900 and $mon is 
# zero based
printf("%04d\/%02d\/%02d %02d:%02d:%02d ", $year+1900, ++$mon, $mday, 
                   $hour, $min, $sec);
