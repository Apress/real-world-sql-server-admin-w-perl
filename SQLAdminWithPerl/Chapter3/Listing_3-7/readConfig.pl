# This script shows how to use the dbaReadConfig() function to read
# entries from a config file. In some scenarios, it's convenient to
# allow duplicate key entries for a section. This is not allowed in 
# a typical Windows INI file.

use strict;
use SQLDBA::Utility qw( dbaReadConfig );  # import the dbaReadConfig() function
use Data::Dumper;

# Get the config file name from the command line
my $iniFile = shift or
   die "***Err: $0 expects a config file.\n";

# Read the config file entries
my $ref = dbaReadConfig($iniFile);  

# Dump out the config file entries
print Dumper($ref);