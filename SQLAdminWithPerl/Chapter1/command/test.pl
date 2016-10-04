use strict;

# Use the backtick operator to run a command line program and
# send the output to the array @result. The command line output
# split by the newline into a list.

my @result = `net users 2>&1`;
foreach my $line (@result) {
  print "** $line ~~";
}