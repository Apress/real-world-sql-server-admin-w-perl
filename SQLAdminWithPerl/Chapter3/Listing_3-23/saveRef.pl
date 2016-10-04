# This script shows how to persist a Perl data structure
# using the function dbaSaveRef(). This function is imported
# from the module SQLDBA::Utility

use strict;
use SQLDBA::Utility qw( dbaSaveRef );  # import the function

my $statusFile = 'statusFile.txt';  # the name of the file where the structure will be saved
my $statusVar = 'status';           # the name of the reference variable in the saved statement
my $ref = alertLogin();             # obtain the reference to the data structure

# Save/persist the data structure
dbaSaveRef($statusFile, $ref, $statusVar);


# This is an arbitrary function whose sole purpose is to
# generate a reference to a data structure for
# illustration purpose.

##################
sub alertLogin {
   # do some monitoring and alerting here
   
   my $statusRef = {
      NYSQL01 => {
         LastAlertedTime => '2003-01-03 20:10:52',
         LastFailedTime => '2003-01-03 23:20:10',
         FailedConsecutiveTimes => 3
      },
      NJSQL01 => {
         LastAlertedTime => '2003-01-01 04:15:24',
         LastFailedTime => '2003-01-03 22:25:45',
         FailedConsecutiveTimes => 2
      }
   };
   return $statusRef;
} # alertLogin