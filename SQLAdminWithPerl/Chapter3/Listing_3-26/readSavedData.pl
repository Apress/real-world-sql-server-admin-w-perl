# This script shows how to read a Perl data structure persisted
# with the function dbaSaveRef(). The script uses the function
# dbaReadSavedRef() to perform the actual read.
# The dbaReadSavedRef() function is imported from the module
# SQLDBA::Utility.

use strict;
use Data::Dumper;
use SQLDBA::Utility qw( dbaReadSavedRef );  # import the function

my $statusFile = 'statusFile.txt';          # identify the file where the data structure was persisted
my $ref = dbaReadSavedRef($statusFile);     # read the data structure from the file

# Print the data structure
print Data::Dumper->Dump([$ref], [ 'status']);
