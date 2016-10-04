# This example shows how to construct a hash of arrays. 
# A hash of Arrays is a hash whose values point to array references.

%properties = ( master => [ 12, '20020528' ],
                tempdb => [ 20, '20020712' ],
                pubs   => [ 3, '20020528' ] );

foreach my $db (sort keys %properties) {  # sort database names alphabetically
    print "Database: $db, ";
    map { print "$_ " }  @{$properties{$db}};
    print "\n";
}
