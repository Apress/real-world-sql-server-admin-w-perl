# This script demonstrates how to remove duplicate elements
# from an array. It uses the map() function to remove 
# duplicates.

use strict;

my @set = (2, 'pubs', 2, 'tempdb', 'tempdb', 1);

my $unique = dbaRemoveDuplicates(\@set);
foreach my $db (@$unique) {
   print "   $db\n";
}

###########################
sub dbaRemoveDuplicates {
   my ($setRef) = shift or
      die "***Err: dbaRemoveDuplicates() expects a reference.";

   my %temp;
   map { $temp{$_} = 1 } @$setRef;
   return [ keys %temp ];
} # dbaRemoveDuplicates
