# This script shows how to use the function dbaSetSame() to
# determine whether two arrays are the same. The function is
# defined in this script. You can also import the function
# from the module SQLDBA:Utility.

use strict;
use SQLDBA::Utility qw( dbaSetDiff ); # import the function dbaSetDiff()

my @set1 = (2, 'pubs', 2, 'tempdb', 'tempdb', 1);
my @set2 = ('northwind', 'model', 1, 'tempdb', 1);

#my @set2 = (2, 'pubs', 2, 'tempdb', 'tempdb', 1);

my $same = dbaSetSame(\@set1, \@set2);
if ($same) {
   print "The two arrays are the same.\n";
}
else {
   print "The two arrays are not the same.\n";
}

###################
sub dbaSetSame {
   my($ref1, $ref2) = @_;
   die "***Err: dbaSetSame() expects two references." unless ref($ref1) && ref($ref2);

   return 0 if scalar dbaSetDiff($ref1, $ref2);
   return 0 if scalar dbaSetDiff($ref2, $ref1);
   return 1;
} # dbaSetSame
