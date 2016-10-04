# This example shows how to construct an array of hashes 
# using a hash of arrays

# Initialize the hash of arrays

%properties = ( master => [ 12, '20020528' ],
                tempdb => [ 20, '20020712' ],
                pubs   => [ 3, '20020528' ] );

# Let's populate an array of hashes

my @prop;
foreach my $db (keys %properties) {
    push @prop, { name => $db,
                  size => $properties{$db}->[0],
                  date => $properties{$db}->[1]  };
}

# Print out the array of hashes

foreach my $h (@prop) {               # $h is a reference to a hash
    foreach my $k (sort keys %$h) {   # $k is a scalar hash key, a string
       print "$k = $h->{$k}\n";
    }
    print "\n";
}
