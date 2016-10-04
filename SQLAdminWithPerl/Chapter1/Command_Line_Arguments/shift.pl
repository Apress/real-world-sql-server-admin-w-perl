use strict;

# Use the shift() function to retrieve the command line arguments

# The shift() gets the first argument and the second shift()
# gets the second argument

my ($arg1, $arg2) = (shift, shift);
print $arg1, ';', $arg2, "\n";
