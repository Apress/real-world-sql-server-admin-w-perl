use strict;

# Use the Getopt::Std module to parse and retrieve the
# command line arguments

use Getopt::Std;

# Initialize the hash to be used to store the command
# line arguments
my %opts;

# Parse and retrieve the command line arguments

getopts('oi:p:', \%opts);

# Now check the status of the expected command line switches
# and their values

if (exists $opts{o}) {
    print "-o siwtch is: $opts{o}\n";
} else {
    print "-o not specified.\n";
}
if (exists $opts{i}) {  # if the switch is present
   if (defined $opts{i}) {  # if the argument is present 
       print "-i switch: $opts{i}\n";
   } else {
       print "-i switch: undef\n";
   }
} else {
    print "-i not specified.\n";
}
if (exists $opts{p}) {
   if (defined $opts{p}) {  # if the argument is present 
       print "-p switch: $opts{p}\n";
   } else {
       print "-p switch: undef\n";
   }
} else {
    print "-p not specified.\n";
}
