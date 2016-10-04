# This script shows how to use the dbaInSet() function.
# The function is defined in the module SQLDBA:Utility.

use strict;
use SQLDBA::Utility qw( dbaInSet );  # import the function dbaInSet()

my $tables = [ '[authors]', 'titles'];

# Check whether a scalar is in the array
if (dbaInSet('[authors]', $tables)) {
  print "It is in the array.\n";
}