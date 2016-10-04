# This script shows how to use the function dbaSetDiff() to
# get the difference between two arrays. The function is
# defined in this script. You can also import the function
# from the module SQLDBA:Utility.

use strict;
use SQLDBA::Utility qw( dbaInSet );

my @set1 = (2, 'pubs', 2, 'tempdb', 'tempdb', 1);
my @set2 = ('northwind', 'model', 1, 'tempdb', 1);

my @common = dbaSetDiff(\@set1, \@set2);
foreach my $db (@common) {
   print "  $db\n";
}

###################
sub dbaSetDiff {
   my ($setRef1, $setRef2) = @_;

   my @diff;
   foreach my $e1 (@$setRef1) {
      if (!dbaInSet($e1, $setRef2)) {
         push @diff, $e1 unless grep($e1 eq $_, @diff);
      }
   }
   @diff;
} # dbaSetDiff
