use strict;

# Initialize the array with a list of strings representing
# database names
my @databases = ('master', 'tempdb', 'ab-c', '[pubs]');

# Loop through the array @databases and test each element
# to determine whether it contains any non-word character (\W)
# Add the database name to the array @nonRegularNames if
# it contains any non-word character
my @nonRegularNames;
foreach my $db (sort @databases) {
    push(@nonRegularNames, $db) if $db =~ /\W/;
}

# Loop through the array @nonRegularNames and
# print each element on a separate line
foreach (@nonRegularNames) {
  print "$_\n";
}

print "\n\nTry grep() function ...\n";

# Use the grep() function to extract the database names
# with a non-word character.
my @nonRegularNames = grep { /\W/ } @databases;

# Again, print all the non regular database names
foreach (@nonRegularNames) {
  print "$_\n";
}
