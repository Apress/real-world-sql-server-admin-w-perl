# This script shows how to use the function dbaSetCommon() to
# get the intersection of two arrays.

# In this sample script, the function dbaSetCommon() is defined
# in the script. But you can also import the function from
# the module SQLDBA::Utility.

use strict;

my @set1 = ('master', 'pubs', 'tempdb', 'tempdb');
my @set2 = ('northwind', 'model', 'master', 'tempdb');

my @common = dbaSetCommon(\@set1, \@set2);
foreach my $db (@common) {
   print "   $db\n";
}


#####################
sub dbaSetCommon {
  my ($setRef1, $setRef2) = @_;

  my @common;
  foreach my $e1 (@$setRef1) {
     foreach my $e2 (@$setRef2) {
        if ($e1 eq $e2) {
           push @common, $e1 unless grep($e1 eq $_, @common);
        }
     }
  }
  @common;
}