# This script shows how to generate a dependency tree, given
# all the immediate dependencies. It uses the function dbaGetTree(),
# which is defined in the script. You can also import it from the
# module SQLDBAL::Utility.

use strict;
use Data::Dumper;

# Prepare the immediate dependencies. These immediate dependencies
# are hard coded in this script for illustration purposes.
my $ref = {
         putOrder => ['getStock', 'getPrice', 'seeCredit'],
         getStock => ['getInStock', 'getOutStock'],
         getPrice => ['calcDisc'],
         seeCredit => ['isBad'],
         getInStock => [],
         getOutStock => ['getLog'],
         getLog => [],
         calcDisc => [],
         isBad => []
};

# Generate the dependency tree using the function dbaGetTree()
my $treeRef = dbaGetTree($ref, [ keys %$ref ], []);
print "putOrder:\n", Dumper($treeRef->{putOrder});    # print the tree for one node
print "seeCredit:\n", Dumper($treeRef->{seeCredit});  # print the tree for another node

#####################
sub dbaGetTree {
   my($lookupRef, $ref, $path) = @_;
   
   my $rc = {};
   foreach my $key (@$ref) {
      if (grep {$key eq $_} @$path) {
         push @$path, $key;
         die "***Err: circular dependency. " . join(', ', @$path);
      }
      my $newPath = [ @$path ];
      push @$newPath, $key;
      $rc->{$key} = dbaGetTree($lookupRef, $lookupRef->{$key}, $newPath);
   }
   return $rc;
} # dbaGetTree
