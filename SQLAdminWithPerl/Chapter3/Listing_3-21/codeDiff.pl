# This script shows how to compare two strings using the
# function dbaStringDiff(). The function is imported from
# the module SQLDBA::Utility.

use strict;
use SQLDBA::Utility qw( dbaStringDiff );  # import the function
use Data::Dumper;

# Define the first sample string
my $s1 =<<EofTSQL1;
   use pubs
   go
   sp_help authors
   go
   select * from authors
    where au_id = '172-32-1176'
   go
EofTSQL1

# Define the second sample string
my $s2 =<<EofTSQL2;
   use pubs
   go
   EXEC sp_help authors
   go
   select * from authors
    where au_id = '172-32-1176'
   go
EofTSQL2

# Now compare the two sample strings and obtain the first 20 characters
# from each of the two strings from the position where the two strings 
# start to differ.
my $ref = dbaStringDiff($s1, $s2, 20);

# print out the difference
print Dumper($ref);

