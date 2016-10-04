# This small Perl script highlights the usefulness of the Data::Dumper 
# module. Module can handle any data structure. For simplicity, only
# a hash is included.

use strict;
use Getopt::Std;
use Data::Dumper;

my %opts;

# Get the command line arguments into the hash %opts
getopts('oi:p:', \%opts);

# Use the Dumper() function from the Data::Dumper module to
# help print out the entire hash. The Dumper() function 
# accepts a reference to the hash (or any other data structure)
print Dumper(\%opts);
