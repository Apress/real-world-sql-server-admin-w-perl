# This script shows how to obtain the difference between two
# date/time strings, using the function dbaTimeDiff() imported 
# from the module SQLDBA::Utility.

use strict;
use SQLDBA::Utility qw( dbaTimeDiff );  # import the function

# Calculate the time difference. The two time strings are
# retrieved from the command line.
my $diff = dbaTimeDiff(shift, shift);
print "Time Diff (seconds): $diff\n";

