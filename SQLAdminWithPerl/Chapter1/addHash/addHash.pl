# The nature of this module is discussed in Chapter 2
# The module is used here to simplify the printing of
# of the hash

use Data::Dumper; 

# Initialize the hash %dbSize with three key/value pairs
%dbSize = (master => 12, tempdb => 13, pubs => 14);

# Loop through the key/value pairs with the each() function
while (($db, $size) = each %dbSize) {
   print "$db = $size\n";
}

# Loop through the key/value pairs with the keys() function in
# an foreach loop.
# This is a typical Perl idiom.
foreach my $db (sort keys %dbSize) {
   print "$db = $dbSize{$db}\n";
}

# Use the Dumper() function from the Data::Dumper module to
# print out the hash
print Dumper(\%dbSize);
