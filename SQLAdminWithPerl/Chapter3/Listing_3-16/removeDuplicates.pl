# This script shows how to use the function dbaRemoveDuplicates()
# to remove duplicate elements from an array.
# The function is defined in this script. You can also choose to
# import it from the module SQLDBA::Utility.

use strict;

# Uncomment the following line to import the function from the
# module SQLDBA::Utility.
#use SQLDBA::Utility qw( dbaRemoveDuplicates );

my @set = (2, 'pubs', 2, 'tempdb', 'tempdb', 1);

my $unique = dbaRemoveDuplicates(\@set);
foreach my $db (@$unique) {
   print "   $db\n";
}

###########################
sub dbaRemoveDuplicates {
   my ($setRef) = shift or
      die "***Err: dbaRemoveDuplicates() expects a reference.";

   my @unique;
   foreach my $e (@$setRef) {
     push @unique, $e unless grep($e eq $_, @unique);
   }
   \@unique;
} # dbaRemoveDuplicates
