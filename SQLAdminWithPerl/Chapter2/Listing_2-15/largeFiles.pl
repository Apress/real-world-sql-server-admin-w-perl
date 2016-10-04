# This script shows how to use the module File::Find to recursively 
# traverse or walk a directory tree and apply operations on the 
# found files.

use strict;
use File::Find;

# use this module to retrieve the command line arguments
use Getopt::Std;

# This hash is used to store the command line arguments
my %opts;

Main: {

   # Get the command line arguments
   getopts('d:s:', \%opts);
   printUsage() unless (defined $opts{d} and defined $opts{s});

   # Start the recursive search, calling the function want()
   # for each file found
   find(\&want, $opts{d});
}

#################
sub want {
   if (-f $_ and -s $_ > $opts{s}) {  # if the current file is larger than the threshold
      print "File: $File::Find::name, Size: ", -s $_, "\n";
   }
}  # wanted

####################
sub printUsage {
   print <<__Usage__;
usage:   
   cmd>perl $0 -d <Directory> -s <Size>
__Usage__
   exit;
}